  for (id, problem) in enumerate(problems)
    if reset_problem
      reset!(problem)
    end
    nequ = problem isa AbstractNLSModel ? problem.nls_meta.nequ : 0
    problem_info = [id; problem.meta.name; problem.meta.nvar; problem.meta.ncon; nequ]
    skipthis = skipif(problem)
    if skipthis
      if first_problem && !prune
        nb_unsuccessful_since_start += 1
      end
      prune || push!(
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
      finalize(problem)
    else
      try
        s = with_logger(solver_logger) do
          solver(problem; kwargs...)
        end
        if first_problem
          for (k, v) in s.solver_specific
            if !(typeof(v) <: AbstractVector)
              insertcols!(
                stats,
                ncol(stats) + 1,
                k => Vector{Union{typeof(v), Missing}}(undef, nb_unsuccessful_since_start),
              )
              push!(specific, k)
            end
          end
          first_problem = false
        end
        counters_list =
          problem isa AbstractNLSModel ?
          [getfield(problem.counters.counters, f) for f in f_counters] :
          [getfield(problem.counters, f) for f in f_counters]
        nls_counters_list =
          problem isa AbstractNLSModel ? [getfield(problem.counters, f) for f in fnls_counters] :
          zeros(Int, length(fnls_counters))
        push!(
          stats,
          [
            solver_name
            problem_info
            s.status
            s.objective
            s.elapsed_time
            s.iter
            s.dual_feas
            s.primal_feas
            counters_list
            nls_counters_list
            ""
            [s.solver_specific[k] for k in specific]
          ],
        )
      catch e
        @error "caught exception" e
        if first_problem
          nb_unsuccessful_since_start += 1
        end
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
            fill(missing, length(specific))
          ],
        )
      finally
        finalize(problem)
      end
    end
    (skipthis && prune) || @info log_row(stats[end, col_idx])
  end