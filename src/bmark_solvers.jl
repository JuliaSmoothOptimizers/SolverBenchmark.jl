export bmark_solvers
using Base.Threads
using DataFrames

"""
    bmark_solvers(solvers :: Dict{Symbol,Any}, args...; kwargs...)

Run a set of solvers on a set of problems. If Threads.@threads is larger than 1, the solvers will be run in parallel.

#### Arguments
* `solvers`: a dictionary of solvers to which each problem should be passed
* other positional arguments accepted by `solve_problems`, except for a solver name

#### Keyword arguments
Any keyword argument accepted by `solve_problems`

#### Return value
A Dict{Symbol, AbstractExecutionStats} of statistics.
"""
function bmark_solvers_threaded(solvers::Dict{Symbol, <:Any}, args...; kwargs...)
  stats = Dict{Symbol, DataFrame}()
  solver_keys = collect(keys(solvers))
  
  @threads for i in 1:length(solver_keys)
      name = solver_keys[i]
      solver = solvers[name]
      @info "running solver $name on thread $(threadid())"
      stats[name] = solve_problems(solver, name, args...; kwargs...)
  end
  
  return stats
end