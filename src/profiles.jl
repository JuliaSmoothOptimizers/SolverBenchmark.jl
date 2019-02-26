import BenchmarkProfiles: performance_profile
using Plots

export performance_profile, profile_solvers

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

"""
    p = profile_solvers(stats, costs, costnames)

Produce performance profiles comparing `solvers` based on the data in `stats`.

Inputs:
- `stats::Dict{Symbol,DataFrame}`: a dictionary of `DataFrame`s containing the
    benchmark results per solver (e.g., produced by `bmark_results_to_dataframes()`)
- `costs::Vector{Function}`: a vector of functions specifying the measures to use in the profiles
- `costnames::Vector{String}`: names to be used as titles of the profiles.

Keyword inputs:
- `width::Int`: Width of each individual plot (Default: 400)
- `height::Int`: Height of each individual plot (Default: 400)

Output:
A Plots.jl plot representing a set of performance profiles comparing the solvers.
The set contains performance profiles comparing all the solvers together on the
measures given in `costs`.
If there are more than two solvers, additional profiles are produced comparing the
solvers two by two on each cost measure.
"""
function profile_solvers(stats::Dict{Symbol,DataFrame},
                         costs::Vector{<:Function},
                         costnames::Vector{String};
                         width::Int=400,
                         height::Int=400
                        )
  solvers = collect(keys(stats))
  dfs = (stats[solver] for solver in solvers)
  Ps = [hcat([cost(df) for df in dfs]...) for cost in costs]

  nprobs = size(stats[first(solvers)], 1)

  # profiles with all solvers
  ps = [performance_profile(Ps[1], string.(solvers), title=costnames[1], legend=:bottomright)]
  for k = 2 : length(Ps)
    push!(ps, performance_profile(Ps[k], string.(solvers), title=costnames[k], legend=false))
  end

  nsolvers = length(solvers)
  ncosts = length(costs)
  if nsolvers > 2
    npairs = 0
    # combinations of solvers 2 by 2
    colors = get_color_palette(:auto, plot_color(:white), nsolvers)
    for i = 2 : nsolvers
      for j = 1 : i-1
        npairs += 1
        pair = [solvers[i], solvers[j]]
        dfs = (stats[solver] for solver in pair)
        Ps = [hcat([cost(df) for df in dfs]...) for cost in costs]

        clrs = [colors[i], colors[j]]
        push!(ps, performance_profile(Ps[1], string.(pair), palette=clrs, legend=:bottomright))
        for k = 2 : length(Ps)
          push!(ps, performance_profile(Ps[k], string.(pair), palette=clrs, legend=false))
        end
      end
    end
    p = plot(ps..., layout=(1 + ipairs, ncosts), size=(ncosts * width, (1 + ipairs) * height))
  else
    p = plot(ps..., layout=(1, ncosts), size=(ncosts * width, height))
  end
  p
end
