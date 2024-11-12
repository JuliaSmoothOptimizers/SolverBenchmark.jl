using Base.Threads

export bmark_solvers
"""
    bmark_solvers(solvers :: Dict{Symbol,Any}, args...; kwargs...)

Run a set of solvers on a set of problems. If Threads.@threads is larger than 1, the solvers will be run in parallel.
Note that the @threads macro requires that the number of threads is set before the Julia process starts, using the -t or --threads command-line argument, or the JULIA_NUM_THREADS environment variable.

#### Arguments
* `solvers`: a dictionary of solvers to which each problem should be passed
* other positional arguments accepted by `solve_problems`, except for a solver name

#### Keyword arguments
Any keyword argument accepted by `solve_problems`

#### Return value
A Dict{Symbol, AbstractExecutionStats} of statistics.
"""

function bmark_solvers(solvers::Dict{Symbol, <:Any}, args...; kwargs...)
  stats = Dict{Symbol, DataFrame}()
  @threads for (name, solver) in collect(pairs(solvers))
      @info "running solver $name"
      stats[name] = solve_problems(solver, name, args...; kwargs...)
  end
  return stats
end