export bmark_solvers

"""
    bmark_solvers(solvers :: Dict{Symbol,Any}, problems; kwargs...)

Run a set of solvers on a set of problems.

#### Arguments

- `solvers`: a dictionary of solvers to which each problem should be passed;
- `problems`: the set of problems to pass to the solver, as an iterable of `AbstractNLPModel`. It is recommended to use a generator expression (necessary for CUTEst problems).

#### Keyword arguments

Any keyword argument accepted by [`solve_problems`](@ref).

#### Return value

A `Dict{Symbol, DataFrame}` of statistics.

#### Examples

```jldoctest; output = false
using ADNLPModels, JSOSolvers, SolverBenchmark
nlps = (
  ADNLPModel(x -> 100 * (x[2] - x[1]^2)^2 + (x[1] - 1)^2, [-1.2; 1.0]),
  ADNLPModel(x -> 4 * (x[2] - x[1]^2)^2 + (x[1] - 1)^2, [-1.2; 1.0]),
)
solvers = Dict(
  :LBFGS => nlp -> lbfgs(nlp; mem = 2, verbose = 0),
  :TRON => nlp -> tron(nlp; verbose = 0),
)
stats = bmark_solvers(solvers, nlps)
keys(stats)

# output

[ Info: running solver TRON
[ Info:          Solver             Name    nvar    ncon           status    iter      Time      f(x)      Dual    Primal  
[ Info:            TRON          Generic       2       0      first_order      23   6.4e-01   6.5e-14   1.2e-06   0.0e+00
[ Info:            TRON          Generic       2       0      first_order      10   4.3e-01   8.0e-20   2.1e-09   0.0e+00
[ Info: running solver LBFGS
[ Info:          Solver             Name    nvar    ncon           status    iter      Time      f(x)      Dual    Primal  
[ Info:           LBFGS          Generic       2       0      first_order      42   3.0e-03   1.3e-18   2.0e-08   0.0e+00
[ Info:           LBFGS          Generic       2       0      first_order      15   0.0e+00   1.7e-15   1.2e-07   0.0e+00
KeySet for a Dict{Symbol, DataFrames.DataFrame} with 2 entries. Keys:
  :TRON
  :LBFGS

```
"""
function bmark_solvers(solvers::Dict{Symbol, <:Any}, args...; kwargs...)
  stats = Dict{Symbol, DataFrame}()
  for (name, solver) in solvers
    @info "running solver $name"
    stats[name] = solve_problems(solver, name, args...; kwargs...)
  end
  return stats
end
