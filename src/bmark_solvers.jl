export bmark_solvers

"""
    bmark_solvers(solvers :: Dict{Symbol,Any}, args...; kwargs...)

Run a set of solvers on a set of problems.

#### Arguments
* `solvers`: a dictionary of solvers to which each problem should be passed
* other positional arguments accepted by `solve_problems`, except for a solver name

#### Keyword arguments
* `parallel::Bool`: whether to run the problems in parallel (default: false). The user is responsible for ensuring that the solvers and problems are thread-safe if this is set to true. Moreover, the number of Julia threads must be set to a value greater than 1 (see `JULIA_NUM_THREADS` environment variable).
All other keyword arguments are given to `solve_problems` or `solve_problems_parallel` if `parallel` is true.

#### Return value
A Dict{Symbol, AbstractExecutionStats} of statistics.
"""
function bmark_solvers(solvers::Dict{Symbol, <:Any}, args...; parallel::Bool = false, kwargs...)
  stats = Dict{Symbol, DataFrame}()
  for (name, solver) in solvers
    @info "running solver $name"
    if parallel && Threads.nthreads() > 1
      stats[name] = solve_problems_parallel(solver, name, args...; kwargs...)
    else
      parallel && @warn "SolverBenchmarks.jl: parallel is set to true but the number of threads is $(Threads.nthreads()). Running in serial mode."
      stats[name] = solve_problems(solver, name, args...; kwargs...)
    end
  end
  return stats
end
