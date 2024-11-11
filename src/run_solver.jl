export solve_problems

"""
    solve_problems(solver, solver_name, problems; kwargs...)

Apply a solver to a set of problems.

#### Arguments
* `solver`: the function name of a solver;
* `solver_name`: name of the solver;
* `problems`: the set of problems to pass to the solver, as an iterable of
  `AbstractNLPModel`. It is recommended to use a generator expression (necessary for
  CUTEst problems).

#### Keyword arguments
* `solver_logger::AbstractLogger`: logger wrapping the solver call (default: `NullLogger`);
* `reset_problem::Bool`: reset the problem's counters before solving (default: `true`);
* `skipif::Function`: function to be applied to a problem and return whether to skip it
  (default: `x->false`);
* `colstats::Vector{Symbol}`: summary statistics for the logger to output during the
benchmark (default: `[:name, :nvar, :ncon, :status, :elapsed_time, :objective, :dual_feas, :primal_feas]`);
* `info_hdr_override::Dict{Symbol,String}`: header overrides for the summary statistics
  (default: use default headers);
* `prune`: do not include skipped problems in the final statistics (default: `true`);
* any other keyword argument to be passed to the solver.

#### Return value
* a `DataFrame` where each row is a problem, minus the skipped ones if `prune` is true.
"""
function solve_problems(
  solver,
  solver_name::TName,
  problems;
  solver_logger::AbstractLogger = NullLogger(),
  reset_problem::Bool = true,
  skipif::Function = x -> false,
  colstats::Vector{Symbol} = [
    :solver_name,
    :name,
    :nvar,
    :ncon,
    :status,
    :iter,
    :elapsed_time,
    :objective,
    :dual_feas,
    :primal_feas,
  ],
  info_hdr_override::Dict{Symbol, String} = Dict{Symbol, String}(:solver_name => "Solver"),
  prune::Bool = true,
  kwargs...,
) where {TName}
  f_counters = collect(fieldnames(Counters))
  fnls_counters = collect(fieldnames(NLSCounters))[2:end] # Excludes :counters
  ncounters = length(f_counters) + length(fnls_counters)
  types = [
    TName
    Int
    String
    Int
    Int
    Int
    Symbol
    Float64
    Float64
    Int
    Float64
    Float64
    fill(Int, ncounters)
    String
  ]
  names = [
    :solver_name
    :id
    :name
    :nvar
    :ncon
    :nequ
    :status
    :objective
    :elapsed_time
    :iter
    :dual_feas
    :primal_feas
    f_counters
    fnls_counters
    :extrainfo
  ]
  stats = DataFrame(names .=> [T[] for T in types])

  specific = Symbol[]

  col_idx = indexin(colstats, names)

  first_problem = true
  fails_since_start = String[]
  @info log_header(colstats, types[col_idx], hdr_override = info_hdr_override)

  for (id, problem) in enumerate(problems)
    if reset_problem
      reset!(problem)
    end
    nequ = problem isa AbstractNLSModel ? problem.nls_meta.nequ : 0
    problem_info = [id; problem.meta.name; problem.meta.nvar; problem.meta.ncon; nequ]
    skipthis = skipif(problem)
    if skipthis
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
              insertcols!(stats, ncol(stats) + 1, k => Vector{Union{typeof(v), Missing}}())
              push!(specific, k)
            end
          end

          for fail in fails_since_start
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
              fail
              fill(missing, length(specific))
            ],
          )
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
        if !first_problem 
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
        else
          push!(fails_since_start, string(e))
        end
      finally
        finalize(problem)
      end
    end
    ((skipthis && prune) || first_problem) || @info log_row(stats[end, col_idx])
    !first_problem || @info log_row(Any[solver_name, problem.meta.name, problem.meta.nvar, problem.meta.ncon, :exception, 0, Inf, Inf, Inf, Inf])
    # TODO: what if log_header override does not have the same default value ?
  end
  return stats
end
