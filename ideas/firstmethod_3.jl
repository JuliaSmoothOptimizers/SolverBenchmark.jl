function solve_problems(
  solver,
  solver_name::TName,
  problems;
  use_thread::Bool = true,
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
      :primal_feas
  ],
  info_hdr_override::Dict{Symbol,String} = Dict{Symbol,String}(:solver_name => "Solver"),
  prune::Bool = true,
  kwargs...,
) where {TName}
  # Collect all problems into a vector for indexing
  problem_list = collect(problems)
  num_problems = length(problem_list)

  # Initialize synchronization primitives
  specific_fields = Ref(Symbol[])  # To store `specific` solver-specific fields
  specific_lock = ReentrantLock()   # Protects access to `specific_fields`

  # Preallocate results array
  # Each result will be a tuple corresponding to the DataFrame columns
  results = Vector{Any}(undef, num_problems)

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
          # Create a skipped problem entry
          return (
              solver_name,
              problem_info...,
              :skipped,
              0,
              Inf,
              0,
              Inf,
              Inf,
              fill(0, length(fieldnames(Counters)) + length(fieldnames(NLSCounters)) - 1),
              "skipped",
              fill(missing, 0)  # Placeholder for specific fields
          )
      else
          try
              # Solve the problem with logging
              s = with_logger(solver_logger) do
                  solver(problem; kwargs...)
              end

              # Extract counters
              f_counters = collect(fieldnames(Counters))
              fnls_counters = length(fieldnames(NLSCounters)) > 1 ? collect(fieldnames(NLSCounters))[2:end] : Symbol[]
              counters_list =
                  problem isa AbstractNLSModel ?
                  [getfield(problem.counters.counters, f) for f in f_counters] :
                  [getfield(problem.counters, f) for f in f_counters]
              nls_counters_list =
                  problem isa AbstractNLSModel ?
                  [getfield(problem.counters, f) for f in fnls_counters] :
                  fill(0, length(fnls_counters))

              # Determine specific fields if not yet set
              lock(specific_lock) do
                  if isempty(specific_fields[])
                      specific_fields[] = Symbol[]
                      for (k, v) in s.solver_specific
                          if !(typeof(v) <: AbstractVector)
                              push!(specific_fields[], k)
                          end
                      end
                  end
              end

              # Collect specific solver fields
              specific_values = [getfield(s.solver_specific, k, missing) for k in specific_fields[]]

              return (
                  solver_name,
                  problem_info...,
                  s.status,
                  s.iter,
                  s.elapsed_time,
                  s.objective,
                  s.dual_feas,
                  s.primal_feas,
                  vcat(counters_list, nls_counters_list),
                  "",
                  specific_values...
              )
          catch e
              @error "Exception in problem $idx: $e"
              return (
                  solver_name,
                  problem_info...,
                  :exception,
                  0,
                  Inf,
                  0,
                  Inf,
                  Inf,
                  fill(0, length(fieldnames(Counters)) + length(fieldnames(NLSCounters)) - 1),
                  string(e),
                  fill(missing, length(specific_fields[]))
              )
          finally
              finalize(problem)
          end
      end
  end

  # If threading is enabled, process in parallel
  if use_thread && num_problems > 0
      Threads.@threads for idx in 1:num_problems
          results[idx] = process_problem(idx)
      end
  else
      # Single-threaded processing
      for idx in 1:num_problems
          results[idx] = process_problem(idx)
      end
  end

  # After processing, determine the DataFrame columns
  # Base columns
  df_columns = [
      :solver_name,
      :name,
      :nvar,
      :ncon,
      :status,
      :iter,
      :elapsed_time,
      :objective,
      :dual_feas,
      :primal_feas
  ]

  # Add counters as separate columns
  f_counters = collect(fieldnames(Counters))
  fnls_counters = length(fieldnames(NLSCounters)) > 1 ? collect(fieldnames(NLSCounters))[2:end] : Symbol[]
  all_counters = vcat(f_counters, fnls_counters)
  df_columns = vcat(df_columns, all_counters)

  # Add extrainfo and specific fields
  df_columns = vcat(df_columns, [:extrainfo], specific_fields[])

  # Prepare data for DataFrame
  df_data = [res for res in results]

  # Create the DataFrame
  stats = DataFrame(df_data, df_columns)

  # Apply column name overrides if any
  for (k, v) in info_hdr_override
      if hasproperty(stats, k)
          rename!(stats, k => v)
      end
  end

  # Remove skipped problems if prune is true
  if prune
      @info "Pruning skipped problems."
      stats = filter(row -> row.status != :skipped && row.status != :exception, stats)
  end

  # Log header and rows
  @info log_header(colstats, types=eltype.(eachcol(stats, colstats)), hdr_override=info_hdr_override)
  for row in eachrow(stats)
      @info log_row(row, colstats)
  end

  return stats
end