export bmark_solvers

"""
    bmark_solvers(solvers :: Dict{Symbol,Any}, args...; kwargs...)

Run a set of solvers on a set of problems.

#### Arguments
* `solvers`: a dictionary of solvers to which each problem should be passed
* other positional arguments accepted by `solve_problems`, except for a solver name

#### Keyword arguments
Any keyword argument accepted by `solve_problems`

#### Return value
A Dict{Symbol, DataFrame} of statistics.
"""
function bmark_solvers(solvers::Dict{Symbol, <:Any}, args...;parallel_eval=false, kwargs...)
  stats = Dict{Symbol, DataFrame}()
  if parallel_eval && length(procs()) > 1
    @info "bmark solvers in parallel"
    future_stats = Dict{Symbol, Future}()
    @sync for (name, solver) in solvers
      @async future_stats[name] = @spawnat :any begin
        @info "worker $(myid()) running solver $(name)"
        solve_problems(solver, args...; kwargs...)
      end
    end
    @sync for (name, future) in future_stats
      @async stats[name] = fetch(future)
    end
  else
    for (name, solver) in solvers
      @debug "running" name solver
      stats[name] = solve_problems(solver, args...; kwargs...)
    end
  end
  return stats
end
