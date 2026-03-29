export bmark_solvers

"""
    bmark_solvers(solvers :: Dict{Symbol,Any}, args...; parallel::Bool=false, kwargs...)

Run a set of solvers on a set of problems.

#### Arguments
* `solvers`: a dictionary of solvers to which each problem should be passed
* `parallel`: if true, runs each solver on a separate worker process (default: false)
* other positional arguments accepted by `solve_problems`, except for a solver name

#### Keyword arguments
Any keyword argument accepted by `solve_problems`

#### Return value
A Dict{Symbol, DataFrame} of statistics.
"""
function bmark_solvers(solvers::Dict{Symbol, <:Any}, args...; parallel::Bool = false, kwargs...)

  # --- 1. SERIAL PATH (Default) ---
  if !parallel
    stats = Dict{Symbol, DataFrame}()
    for (name, solver) in solvers
      @info "Running solver $name (Serial)"
      stats[name] = solve_problems(solver, name, args...; kwargs...)
    end
    return stats
  end

  # --- 2. PARALLEL PATH (By Solver) ---
  if nworkers() == 1
    @warn "parallel=true but only 1 worker process found. Did you forget `addprocs()`?"
  end

  # Helper function runs on the worker
  # It takes a pair (:solver_name, solver_function)
  run_solver_worker = function (solver_pair)
    sname, sfunc = solver_pair
    @info "Worker $(myid()) running solver $sname"
    result_df = solve_problems(sfunc, sname, args...; kwargs...)
    return (sname, result_df)
  end

  # Collect solvers into a list so pmap can distribute them
  solver_list = collect(solvers)

  # Distribute work
  results = pmap(run_solver_worker, solver_list)

  # Aggregate results back into the Dict
  stats = Dict{Symbol, DataFrame}()
  for (name, df) in results
    stats[name] = df
  end

  return stats
end
