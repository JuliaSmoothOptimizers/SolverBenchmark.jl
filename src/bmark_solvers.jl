using Base.Threads

export bmark_solvers
"""
    bmark_solvers(solvers :: Dict{Symbol, Any}, args...; threads_enable=false, kwargs...)

Run a set of solvers on a set of problems. If `threads_enable` is set to true and the number of Julia threads is greater than 1, 
the solvers will be run in parallel using `Threads.@threads`.

Note: The `@threads` macro requires that the number of threads be set before the Julia process starts, using the `-t` or `--threads`
command-line argument, or the `JULIA_NUM_THREADS` environment variable.

#### Arguments
* `solvers`: a dictionary of solvers to which each problem should be passed
* other positional arguments accepted by `solve_problems`, except for a solver name

#### Keyword arguments
Any keyword argument accepted by `solve_problems`
* `threads_enable`: A boolean indicating whether to enable multithreading. Default is `false`.

#### Return value
A Dict{Symbol, AbstractExecutionStats} of statistics.
"""

function bmark_solvers(solvers::Dict{Symbol, <:Any}, args...; threads_enable=false, kwargs...)
  stats = Dict{Symbol, DataFrame}()
  
  if threads_enable
      @info "Running with multithreading enabled"
      Threads.@threads for i in 1:length(solvers)
          name = keys(solvers)[i]
          solver = solvers[name]
          @info "Running solver $name on thread $(Threads.threadid())"
          stats[name] = solve_problems(solver, name, args...; kwargs...)
      end
  else
      for (name, solver) in solvers
          @info "Running solver $name"
          stats[name] = solve_problems(solver, name, args...; kwargs...)
      end
  end
  
  return stats
end