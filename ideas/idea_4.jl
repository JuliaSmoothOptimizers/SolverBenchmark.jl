using Base.Threads

# Initialize shared variables
first_problem = Atomic{Bool}(true)  # Atomic flag for the first problem
nb_unsuccessful_since_start = Atomic{Int}(0)  # Atomic counter
stats_lock = ReentrantLock()  # Lock for modifying shared data structures
stats = DataFrame()  # Assuming stats is a DataFrame
specific = []  # Shared array for storing specific keys

# Assume other necessary variables are defined (e.g., solver_name, prune, ncounters, etc.)

# Function to process a single problem
function process_problem(idx)
    problem = problem_list[idx]

    # Reset the problem, if requested
    if reset_problem
        reset!(problem)
    end

    # Problem metadata
    nequ = problem isa AbstractNLSModel ? problem.nls_meta.nequ : 0
    problem_info = [idx; problem.meta.name; problem.meta.nvar; problem.meta.ncon; nequ]

    # Determine if the problem should be skipped
    skipthis = skipif(problem)

    # Check if this problem should be skipped
    if skipthis
        if atomic_get(first_problem) && !prune
            atomic_add!(nb_unsuccessful_since_start, 1)
        end
        if !prune
            lock(stats_lock) do
                # Safely push data into stats
                push!(
                    stats,
                    [
                        solver_name
                        problem_info
                        :exception
                        Inf
                        Inf
                        0
                        Inf
                        Inf
                        fill(0, ncounters)
                        "skipped"
                        fill(missing, length(specific))
                    ],
                )
            end
        end
        finalize(problem)
        return
    else
        try
            result = with_logger(solver_logger) do
                solver(problem; kwargs...)
            end

            # Handle first problem (thread-safe updates)
            if compare_and_swap!(first_problem, true, false)
                lock(stats_lock) do
                    for (k, v) in result.solver_specific
                        if !(v isa AbstractVector)
                            insertcols!(
                                stats,
                                ncol(stats) + 1,
                                k => Vector{Union{typeof(v), Missing}}(
                                    undef,
                                    atomic_get(nb_unsuccessful_since_start),
                                ),
                            )
                            push!(specific, k)
                        end
                    end
                end
            end

            # Collect counters
            counters_list =
                problem isa AbstractNLSModel ?
                [getfield(problem.counters.counters, f) for f in f_counters] :
                [getfield(problem.counters, f) for f in f_counters]
            nls_counters_list =
                problem isa AbstractNLSModel ?
                [getfield(problem.counters, f) for f in fnls_counters] :
                zeros(Int, length(fnls_counters))

            # Add the result to `stats` safely
            lock(stats_lock) do
                push!(
                    stats,
                    [
                        solver_name
                        problem_info
                        result.status
                        result.objective
                        result.elapsed_time
                        result.iter
                        result.dual_feas
                        result.primal_feas
                        counters_list
                        nls_counters_list
                        ""
                        [result.solver_specific[k] for k in specific]
                    ],
                )
            end

        catch e
            @error "Caught exception for problem $idx: $e"

            if atomic_get(first_problem)
                atomic_add!(nb_unsuccessful_since_start, 1)
            end

            lock(stats_lock) do
                len_specific = length(specific)
                push!(
                    stats,
                    [
                        solver_name
                        problem_info
                        :exception
                        Inf
                        Inf
                        0
                        Inf
                        Inf
                        fill(0, ncounters)
                        string(e)
                        fill(missing, len_specific)
                    ],
                )
            end

        finally
            finalize(problem)
        end
    end
    # You can include logging or additional operations here
end

# Multithreaded or single-threaded execution
if use_threads
    Threads.@threads for idx = 1:num_problems
        process_problem(idx)
    end
else
    for idx = 1:num_problems
        process_problem(idx)
    end
end