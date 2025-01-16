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
A Dict{Symbol, AbstractExecutionStats} of statistics.
"""
function bmark_solvers(solvers::Dict{Symbol, <:Any}, args...; kwargs...)
    tasks = Vector{Task}(undef, length(solvers))
    names = Vector{Symbol}(undef, length(solvers))
    idx = 0
    for (name, solver) in solvers
        idx += 1
        names[idx] = name
        tasks[idx] = Threads.@spawn begin
            @info "running solver $name"
            solve_problems(solver, name, args...; kwargs...)
        end
    end

  stats = Dict{Symbol, DataFrame}()
  for (name, solver) in solvers
    @info "running solver $name"
    stats[name] = solve_problems(solver, name, args...; kwargs...)
  end
  return stats
end
