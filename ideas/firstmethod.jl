function solve_problems(
  solver,
  solver_name::TName,
  problems;
  use_threads::Bool = true,
  solver_logger::AbstractLogger = NullLogger(),
  reset_problem::Bool = true,
  skipif::Function = x -> false,
  colstats::Vector{Symbol} = [
    :solver_name,
    :name,
    :nvar,
    :ncon,
    :status,
    :iter,
    :elapsed_time,
    :objective,
    :dual_feas,
    :primal_feas,
  ],
  info_hdr_override::Dict{Symbol, String} = Dict{Symbol, String}(:solver_name => "Solver"),
  prune::Bool = true,
  kwargs...,
) where {TName}
  f_counters = collect(fieldnames(Counters))
  fnls_counters = collect(fieldnames(NLSCounters))[2:end] # Excludes :counters
  ncounters = length(f_counters) + length(fnls_counters)
  types = [
    TName
    Int
    String
    Int
    Int
    Int
    Symbol
    Float64
    Float64
    Int
    Float64
    Float64
    fill(Int, ncounters)
    String
  ]
  names = [
    :solver_name
    :id
    :name
    :nvar
    :ncon
    :nequ
    :status
    :objective
    :elapsed_time
    :iter
    :dual_feas
    :primal_feas
    f_counters
    fnls_counters
    :extrainfo
  ]
  stats = DataFrame(names .=> [T[] for T in types])

  # Create a mutex to protect access to `stats`
  stats_lock = Threads.Mutex()

  # A function that safely pushes data to `stats`
  function safe_push!(data_entry)
      lock(stats_lock) do
          push!(stats, data_entry)
      end
  end
  #safe_push!(data_entry)

  specific = Symbol[]
  condition_lock = Mutex()  # Mutex to protect access to `a` and `b`
  condition_signal = Threads.Condition()  # Condition for signaling thread readiness


  col_idx = indexin(colstats, names)

  first_problem =  Ref(true)  # A shared `Ref` for thread-safe condition
  nb_unsuccessful_since_start = 0
  @info log_header(colstats, types[col_idx], hdr_override = info_hdr_override)


  # Collect all problems into a vector for indexing
  problem_list = collect(problems)
  num_problems = length(problem_list)

  # Function to process a single problem
  function process_problem(idx)
    problem = problem_list[idx]

    # Reset problem if needed
    if reset_problem
        reset!(problem)
    end

    # Extract problem information
    nequ = problem isa AbstractNLSModel ? problem.nls_meta.nequ : 0
    problem_info = (
        solver_name,
        problem.meta.name,
        problem.meta.nvar,
        problem.meta.ncon,
        nequ
    )

    # Determine if the problem should be skipped
    skipthis = skipif(problem)

    if skipthis
      if first_problem && !prune
        nb_unsuccessful_since_start += 1
      end
      prune || safe_push!([
        solver_name
        problem_info
        :exception
        Inf
        Inf
        0
        Inf
        Inf
        fill(0, ncounters)
        "skipped"
        fill(missing, length(specific))
      ]) 
      finalize(problem)
    else
      try
        s = with_logger(solver_logger) do
          solver(problem; kwargs...)
        end
        lock(condition_lock) do
          if first_problem[]     
            for (k, v) in s.solver_specific
              if !(typeof(v) <: AbstractVector)
                insertcols!(
                  stats,
                  ncol(stats) + 1,
                  k => Vector{Union{typeof(v), Missing}}(undef, nb_unsuccessful_since_start),
                )
                push!(specific, k)
              end
            end
            first_problem[] = false
            notify(condition_signal)  # Notify other threads
          end
        end

        counters_list =
          problem isa AbstractNLSModel ?
          [getfield(problem.counters.counters, f) for f in f_counters] :
          [getfield(problem.counters, f) for f in f_counters]
        nls_counters_list =
          problem isa AbstractNLSModel ? [getfield(problem.counters, f) for f in fnls_counters] :
          zeros(Int, length(fnls_counters))
        safe_push!(
          [
            solver_name
            problem_info
            s.status
            s.objective
            s.elapsed_time
            s.iter
            s.dual_feas
            s.primal_feas
            counters_list
            nls_counters_list
            ""
            [s.solver_specific[k] for k in specific]
          ],
        )
      catch e
        @error "caught exception" e
        if first_problem
          nb_unsuccessful_since_start += 1
        end
        safe_push!(
          [
            solver_name
            problem_info
            :exception
            Inf
            Inf
            0
            Inf
            Inf
            fill(0, ncounters)
            string(e)
            fill(missing, length(specific))
          ],
        )
      finally
        finalize(problem)
      end
    end
    (skipthis && prune) || @info log_row(stats[end, col_idx])
    end
end

  # If threading is enabled, process in parallel
  if use_thread && num_problems > 0
    Threads.@threads for idx in 1:num_problems
        process_problem(idx)
    end
else
    # Single-threaded processing
    for idx in 1:num_problems
          process_problem(idx)
    end
end




  return stats
end