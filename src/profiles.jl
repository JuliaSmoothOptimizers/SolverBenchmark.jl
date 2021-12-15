import BenchmarkProfiles: performance_profile
using BenchmarkProfiles, Plots

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
function performance_profile(stats::Dict{Symbol, DataFrame}, cost::Function, args...; kwargs...)
  solvers = keys(stats)
  dfs = (stats[s] for s in solvers)
  P = hcat([cost(df) for df in dfs]...)
  performance_profile(PlotsBackend(), P, string.(solvers), args...; kwargs...)
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
function profile_solvers(
  stats::Dict{Symbol, DataFrame},
  costs::Vector{<:Function},
  costnames::Vector{String};
  width::Int = 400,
  height::Int = 400,
)
  solvers = collect(keys(stats))
  dfs = (stats[solver] for solver in solvers)
  Ps = [hcat([Float64.(cost(df)) for df in dfs]...) for cost in costs]

  nprobs = size(stats[first(solvers)], 1)
  nsolvers = length(solvers)
  ncosts = length(costs)
  npairs = div(nsolvers * (nsolvers - 1), 2)
  colors = get_color_palette(:auto, nsolvers)

  # profiles with all solvers
  ps = [
    performance_profile(
      PlotsBackend(),
      Ps[1],
      string.(solvers),
      palette = colors,
      title = costnames[1],
      legend = :bottomright,
    ),
  ]
  nsolvers > 2 && xlabel!(ps[1], "")
  for k = 2:ncosts
    p = performance_profile(
      PlotsBackend(),
      Ps[k],
      string.(solvers),
      palette = colors,
      title = costnames[k],
      legend = false,
    )
    nsolvers > 2 && xlabel!(p, "")
    ylabel!(p, "")
    push!(ps, p)
  end

  if nsolvers > 2
    ipairs = 0
    # combinations of solvers 2 by 2
    for i = 2:nsolvers
      for j = 1:(i - 1)
        ipairs += 1
        pair = [solvers[i], solvers[j]]
        dfs = (stats[solver] for solver in pair)
        Ps = [hcat([Float64.(cost(df)) for df in dfs]...) for cost in costs]

        clrs = [colors[i], colors[j]]
        p = performance_profile(
          PlotsBackend(),
          Ps[1],
          string.(pair),
          palette = clrs,
          legend = :bottomright,
        )
        ipairs < npairs && xlabel!(p, "")
        push!(ps, p)
        for k = 2:length(Ps)
          p = performance_profile(
            PlotsBackend(),
            Ps[k],
            string.(pair),
            palette = clrs,
            legend = false,
          )
          ipairs < npairs && xlabel!(p, "")
          ylabel!(p, "")
          push!(ps, p)
        end
      end
    end
    p = plot(ps..., layout = (1 + ipairs, ncosts), size = (ncosts * width, (1 + ipairs) * height))
  else
    p = plot(ps..., layout = (1, ncosts), size = (ncosts * width, height))
  end
  p
end
