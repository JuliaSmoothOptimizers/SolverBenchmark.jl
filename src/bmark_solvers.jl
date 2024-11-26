using Base.Threads

export bmark_solvers

"""
    bmark_solvers(solvers :: Dict{Symbol, Any}, args...; kwargs...)

Run a set of solvers on a set of problems. If `JULIA_NUM_THREADS` is set to a number greater than 1, 
the solvers will be run in parallel using `Threads.@threads`.

Note: The `@threads` macro requires that the number of threads be set before the Julia process starts, using the `-t` or `--threads`
command-line argument, or the `JULIA_NUM_THREADS` environment variable.

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
    for i in 1:length(tasks)
        result = fetch(tasks[i])
        stats[names[i]] = result
    end
    return stats
end