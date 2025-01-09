export solve_problems

"""
    solve_problems(solver, solver_name, problems; kwargs...)

Apply a solver to a set of problems.

#### Arguments
* `solver`: the function name of a solver;
* `solver_name`: name of the solver;
* `problems`: the set of problems to pass to the solver, as an iterable of
  `AbstractNLPModel`. It is recommended to use a generator expression (necessary for
  CUTEst problems).

#### Keyword arguments
* `use_threads::Bool`: whether to use threads (default: `true`);
* `solver_logger::AbstractLogger`: logger wrapping the solver call (default: `NullLogger`);
* `reset_problem::Bool`: reset the problem's counters before solving (default: `true`);
* `skipif::Function`: function to be applied to a problem and return whether to skip it
  (default: `x->false`);
* `colstats::Vector{Symbol}`: summary statistics for the logger to output during the
benchmark (default: `[:name, :nvar, :ncon, :status, :elapsed_time, :objective, :dual_feas, :primal_feas]`);
* `info_hdr_override::Dict{Symbol,String}`: header overrides for the summary statistics
  (default: use default headers);
* `prune`: do not include skipped problems in the final statistics (default: `true`);
* any other keyword argument to be passed to the solver.

#### Return value
* a `DataFrame` where each row is a problem, minus the skipped ones if `prune` is true.
"""
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
  info_hdr_override::Dict{Symbol, String} = Dict(:solver_name => "Solver"),
  prune::Bool = true,
  kwargs...,
) where {TName}

  # Collect information about counters
  f_counters = collect(fieldnames(Counters))
  fnls_counters = collect(fieldnames(NLSCounters))[2:end] # Excludes :counters
  ncounters = length(f_counters) + length(fnls_counters)

  # Prepare column types and names for the stats DataFrame
  types = [
      TName,
      Int,
      String,
      Int,
      Int,
      Int,
      Symbol,
      Float64,
      Float64,
      Int,
      Float64,
      Float64,
      Vector{Int},
      String
  ]
  names = [
      :solver_name,
      :id,
      :name,
      :nvar,
      :ncon,
      :nequ,
      :status,
      :objective,
      :elapsed_time,
      :iter,
      :dual_feas,
      :primal_feas,
      :counters,
      :extrainfo
  ]
  stats = DataFrame(names .=> [Vector{T}() for T in types])

  # Thread-safe mechanisms
  stats_lock = Threads.Mutex()
  first_problem = Atomic{Bool}(true)  # Atomic for safe interaction
  specific = Atomic{Vector{Symbol}}([])  # Use atomic for thread-safe updates
  nb_unsuccessful_since_start = Atomic{Int}(0)

  # Prepare DataFrame columns for logging
  col_idx = indexin(colstats, names)
  @info log_header(colstats, types[col_idx], hdr_override = info_hdr_override)

  # Convert problems to an indexable vector
  problem_list = collect(problems)
  num_problems = length(problem_list)

  # Function to safely push data to the DataFrame
  function safe_push!(data_entry)
      lock(stats_lock) do
          push!(stats, data_entry)
      end
  end

  # Function to process a single problem
  function process_problem(idx)
      problem = problem_list[idx]

      # Reset the problem, if requested
      if reset_problem
          reset!(problem)
      end

      # Problem metadata
      nequ = problem isa AbstractNLSModel ? problem.nls_meta.nequ : 0
      problem_info = [
          solver_name,
          idx,
          getfield(problem.meta, :name, ""),
          getfield(problem.meta, :nvar, 0),
          getfield(problem.meta, :ncon, 0),
          nequ
      ]

      # Check if this problem should be skipped
      if skipif(problem)
          if prune
              return
          end

          if first_problem[] && prune
              atomic_add!(nb_unsuccessful_since_start, 1)
          end

          skipped_entry = [
              solver_name,
              idx,
              problem.meta.name,
              problem.meta.nvar,
              problem.meta.ncon,
              nequ,
              :skipped,
              Inf,
              Inf,
              0,
              Inf,
              Inf,
              fill(0, ncounters),
              "skipped"
          ]
          safe_push!(skipped_entry)
          finalize(problem)
          return
      end

      # Solve the problem
      try
          result = with_logger(solver_logger) do
              solver(problem; kwargs...)
          end

          # Handle first problem (thread-safe updates)
          if atomic_get!(first_problem)
              lock(stats_lock) do
                  for (k, v) in result.solver_specific
                      if !(typeof(v) <: AbstractVector)
                          insertcols!(
                              stats,
                              ncol(stats) + 1,
                              k => Vector{Union{typeof(v), Missing}}(undef, nb_unsuccessful_since_start[]),
                          )
                          push!(specific[], k)
                      end
                  end
              end
          end

          # Collect counters
          counters_list = problem isa AbstractNLSModel ?
              [getfield(problem.counters.counters, f) for f in f_counters] :
              [getfield(problem.counters, f) for f in f_counters]
          nls_counters_list = problem isa AbstractNLSModel ?
              [getfield(problem.counters, f) for f in fnls_counters] :
              zeros(Int, length(fnls_counters))

          # Add the result to `stats`
          entry = [
              solver_name,
              idx,
              problem.meta.name,
              problem.meta.nvar,
              problem.meta.ncon,
              nequ,
              result.status,
              result.objective,
              result.elapsed_time,
              result.iter,
              result.dual_feas,
              result.primal_feas,
              counters_list,
              ""  # extrainfo
          ]
          safe_push!(entry)

      catch e
          @error "Caught exception for problem $idx: $e"

          if atomic_get!(first_problem)
              atomic_add!(nb_unsuccessful_since_start, 1)
          end

          failed_entry = [
              solver_name,
              idx,
              problem.meta.name,
              problem.meta.nvar,
              problem.meta.ncon,
              nequ,
              :exception,
              Inf,
              Inf,
              0,
              Inf,
              Inf,
              fill(0, ncounters),
              string(e)
          ]
          safe_push!(failed_entry)
      finally
          finalize(problem)
      end
  end

  # Multithreaded or single-threaded execution
  if use_threads && num_problems > 0
      Threads.@threads for idx in 1:num_problems
          process_problem(idx)
      end
  else
      for idx in 1:num_problems
          process_problem(idx)
      end
  end

  return stats
end
