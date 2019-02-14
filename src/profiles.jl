import BenchmarkProfiles: performance_profile

export performance_profile

"""
    performance_profile(stats, cost)

Produce a performance profile comparing solvers in `stats` using the `cost` function.

Inputs:
- `stats::Dict{Symbol,DataFrame}`: pairs of `:solver => df`;
- `cost::Function`: cost function applyed to each `df`. Should return a vector with the cost of solving the problem at each row;
  - 0 cost is not allowed;
  - If the solver did not solve the problem, return Inf or a negative number.

Examples of cost functions:
- `cost(df) = df.elapsed_time`: Simple `elapsed_time` cost. Assumes the solver solved the problem.
- `cost(df) = (df.status .!= :first_order) * Inf + df.elapsed_time`: Takes into consideration the status of the solver.
"""
function performance_profile(stats::Dict{Symbol,DataFrame}, cost::Function)
  solvers = keys(stats)
  dfs = (stats[s] for s in solvers)
  P = hcat([cost(df) for df in dfs]...)
  performance_profile(P, string.(solvers))
end
