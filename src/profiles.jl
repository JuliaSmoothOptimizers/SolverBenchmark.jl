import BenchmarkProfiles: performance_profile
using BenchmarkProfiles, Plots, CSV

export performance_profile, profile_solvers, export_profile_solvers_data

"""
    performance_profile(stats, cost, args...; b = PlotsBackend(), kwargs...)

Produce a performance profile comparing solvers in `stats` using the `cost` function.

Inputs:
- `stats::Dict{Symbol,DataFrame}`: pairs of `:solver => df`;
- `cost::Function`: cost function applyed to each `df`. Should return a vector with the cost of solving the problem at each row;
  - 0 cost is not allowed;
  - If the solver did not solve the problem, return Inf or a negative number.
- `b::BenchmarkProfiles.AbstractBackend` : backend used for the plot.

Examples of cost functions:
- `cost(df) = df.elapsed_time`: Simple `elapsed_time` cost. Assumes the solver solved the problem.
- `cost(df) = (df.status .!= :first_order) * Inf + df.elapsed_time`: Takes into consideration the status of the solver.
"""
function performance_profile(
  stats::Dict{Symbol, DataFrame},
  cost::Function,
  args...;
  b::BenchmarkProfiles.AbstractBackend = PlotsBackend(),
  kwargs...,
)
  solvers = keys(stats)
  dfs = (stats[s] for s in solvers)
  P = hcat([cost(df) for df in dfs]...)
  performance_profile(b, P, string.(solvers), args...; kwargs...)
end

"""
    p = profile_solvers(stats, costs, costnames;
                        width = 400, height = 400,
                        b = PlotsBackend(), kwargs...)

Produce performance profiles comparing `solvers` based on the data in `stats`.

Inputs:
- `stats::Dict{Symbol,DataFrame}`: a dictionary of `DataFrame`s containing the
    benchmark results per solver (e.g., produced by `bmark_results_to_dataframes()`)
- `costs::Vector{Function}`: a vector of functions specifying the measures to use in the profiles
- `costnames::Vector{String}`: names to be used as titles of the profiles.

Keyword inputs:
- `width::Int`: Width of each individual plot (Default: 400)
- `height::Int`: Height of each individual plot (Default: 400)
- `b::BenchmarkProfiles.AbstractBackend` : backend used for the plot.

Additional `kwargs` are passed to the `plot` call.

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
  b::BenchmarkProfiles.AbstractBackend = PlotsBackend(),
  kwargs...,
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
      b,
      Ps[1],
      string.(solvers),
      palette = colors,
      title = costnames[1],
      legend = :bottomright
    ),
  ]
  nsolvers > 2 && xlabel!(ps[1], "")
  for k = 2:ncosts
    p = performance_profile(
      b,
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
        p = performance_profile(b, Ps[1], string.(pair), palette = clrs, legend = :bottomright)
        ipairs < npairs && xlabel!(p, "")
        push!(ps, p)
        for k = 2:length(Ps)
          p = performance_profile(b, Ps[k], string.(pair), palette = clrs, legend = false)
          ipairs < npairs && xlabel!(p, "")
          ylabel!(p, "")
          push!(ps, p)
        end
      end
    end
    p = plot(
      ps...,
      layout = (1 + ipairs, ncosts),
      size = (ncosts * width, (1 + ipairs) * height);
      kwargs...,
    )
  else
    p = plot(ps..., layout = (1, ncosts), size = (ncosts * width, height); kwargs...)
  end
  p
end

"""
    get_profile_solvers_data(stats, costs; kwargs)

Exports performance profiles plot data comparing `solvers` based on the data in `stats` in a .csv file.
Data are padded with NaN to ensure .csv consistency.

Inputs:
- `stats::Dict{Symbol,DataFrame}`: a dictionary of `DataFrame`s containing the
    benchmark results per solver (e.g., produced by `bmark_results_to_dataframes()`)
- `costs::Vector{Function}`: a vector of functions specifying the measures to use in the profiles

Keyword arguments:
`kwargs` are passed to `BenchmarkProfiles.performance_profile_data()`.

Output:
x_mat, y_mat: vector #costs elements containing matrices containing the x and y coordinate of the plots. Matrices are padded with NaN if necessary (plots do not have the same number of points).
"""
function get_profile_solvers_data(
  stats::Dict{Symbol, DataFrame},
  costs::Vector{<:Function};
  kwargs...
  )

  solvers = collect(keys(stats))
  dfs = (stats[solver] for solver in solvers)
  Ps = [hcat([Float64.(cost(df)) for df in dfs]...) for cost in costs]
 
  nprobs = size(stats[first(solvers)], 1)
  nsolvers = length(solvers)
  ncosts = length(costs)
  npairs = div(nsolvers * (nsolvers - 1), 2)
  x_data, y_data = performance_profile_data(Ps[1]; kwargs...)
  nmaxrow = maximum(length.(x_data))
  for i in eachindex(x_data)
    append!(x_data[i],[NaN for i=1:nprobs-length(x_data[i])])
    append!(y_data[i],[NaN for i=1:nprobs-length(y_data[i])])
  end
  x_mat = [hcat(x_data...)]
  y_mat = [hcat(y_data...)]
  for k in 2:ncosts
    x_data, y_data = performance_profile_data(Ps[k];kwargs...)
    nmaxrow = max(nmaxrow,maximum(length.(x_data)))
    for i in eachindex(x_data)
      append!(x_data[i],[NaN for i=1:nprobs-length(x_data[i])])
      append!(y_data[i],[NaN for i=1:nprobs-length(y_data[i])])
    end
    push!(x_mat, hcat(x_data...))
    push!(y_mat, hcat(y_data...))
  end
  return [m[1:nmaxrow,:] for m in x_mat], [m[1:nmaxrow,:] for m in y_mat]
end

"""
    export_profile_solvers_data(stats, costs, costnames, filename; one_file=true, two_by_two=false, kwargs...)

Exports performance profiles plot data comparing `solvers` based on the data in `stats` in a .csv file.
Data are padded with NaN to ensure .csv consistency.

Inputs:
- `stats::Dict{Symbol,DataFrame}`: a dictionary of `DataFrame`s containing the
    benchmark results per solver (e.g., produced by `bmark_results_to_dataframes()`)
- `costs::Vector{Function}`: a vector of functions specifying the measures to use in the profiles
- `costnames::Vector{String}`: names to be used as titles of the profiles.
- `filename::String`: path to the export file. Do not add .csv extention to the file name.

Keyword arguments:
- `one_file::Bool`: export one file per cost if false, otherwise profiles for all costs are exported in a single file
- `header::Vector{Vector{String}}`: Contains .csv file(s) column names for each files. Example for two costs exported in two files and two solvers "alpha" and "beta": `[ ["alpha_x","alpha_y","beta_x","beta_y"] for _=1:2]`. Note that `header` value does not change columns order in .csv exported files (see Output). 

Additional `kwargs` are passed to `BenchmarkProfiles.performance_profile_data()`.

Output:
File(s) containing profile data in .csv format.
* If one_file=true, returns one file containing the data for all solvers and cost. 
  Columns are cost1_solver1_x, cost1_solver1_y, cost1_solver2_x, ... cost2_solver1_x, cost2_solver1_y, ...
* If one_file=false, returns as many files as the number of cost. 
  The names of the files contain the name of the cost, and the columns are
  solver1_x, solver1_y, solver2_x, ...
"""
function export_profile_solvers_data(
  stats::Dict{Symbol, DataFrame},
  costs::Vector{<:Function},
  costnames::S,
  filename::String;
  header = [],
  one_file=true,
  kwargs...
  ) where {S <: Vector{String}}
  solvers = collect(keys(stats))
  nprobs = size(stats[first(solvers)], 1)
  nsolvers = length(solvers)
  solver_names = String.(keys(stats))
  csv_header = Vector{String}[]
  
  x_mat, y_mat = get_profile_solvers_data(stats,costs;kwargs...)
  if one_file
    if isempty(header) 
      csv_header = vcat([vcat([[cname*"_"*sname*"_x",cname*"_"*sname*"_y"] for sname in solver_names]...) for cname in costnames]...)
    else 
      csv_header = vcat(header...)
    end
    x_mat = hcat(x_mat...)
    y_mat = hcat(y_mat...)
    ncol = size(x_mat)[2]
    nrow = size(x_mat)[1]
    data = Matrix{Float64}(undef,nrow,ncol*2)
    for i =0:ncol-1
      data[:,2*i+1] .= x_mat[:,i+1]
      data[:,2*i+2] .= y_mat[:,i+1]
    end
    CSV.write(filename*".csv",Tables.table(data),header=csv_header)
  else
    csv_header = vcat([[sname*"_x",sname*"_y"] for sname in solver_names]...)
    data = Matrix{Float64}(undef,nprobs,nsolvers*2)
    for k in eachindex(costs)
      if !isempty(header)
        csv_header = header[k]
      end
      for i =0:nsolvers-1
        data[:,2*i+1] .= x_mat[k][:,i+1]
        data[:,2*i+2] .= y_mat[k][:,i+1]
      end
      CSV.write(filename*"_$(costnames[k]).csv",Tables.table(data),header=csv_header)
    end 
  end
end