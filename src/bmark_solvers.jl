export bmark_solvers

using Base.Threads
using DataFrames

export bmark_solvers
"""
    bmark_solvers(solvers :: Dict{Symbol,Any}, args...; kwargs...)

Run a set of solvers on a set of problems. If Threads.@threads is larger than 1, the solvers will be run in parallel.
Note that the @threads macro requires that the number of threads be set before the Julia process starts, using the -t or --threads command-line argument, or the JULIA_NUM_THREADS environment variable.

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


"""
    bmark_solvers_parallel(solvers :: Dict{Symbol, Any}, args...; kwargs...)

Run a set of solvers on a set of problems in parallel.

#### Arguments
* `solvers`: a dictionary of solvers to which each problem should be passed.
* `args...`: other positional arguments accepted by `solve_problems`, except for a solver name.

#### Keyword arguments
Any keyword argument accepted by `solve_problems`.

#### Return value
A `Dict{Symbol, DataFrame}` of execution statistics, with each solver's results stored under its corresponding key.
"""


function bmark_solvers_parallel(solvers::Dict{Symbol, <:Any}, args...; kwargs...)
  stats = Dict{Symbol, DataFrame}()

  # Collect solvers in a vector so we can iterate them in parallel
  solver_keys = collect(keys(solvers))
  solver_values = collect(values(solvers))

  Threads.@threads for i in eachindex(solver_keys)
      name = solver_keys[i]
      solver = solver_values[i]
      @info "Running solver $name on thread $(threadid())"

      # Compute the result for this solver
      result = solve_problems(solver, name, args...; kwargs...)

      # Update the shared stats dictionary safely
      # This is a workaround for the lack of thread-safe dictionaries in Julia, so if two solver finish at same time, one of them will lock the stats first then the other one will wait until the lock is released to update the stats
      lock = ReentrantLock()  # Create a lock for thread-safe dictionary update
      lock(()-> stats[name] = result)
  end

  return stats
end