# need to have done, e.g.,
# results = PkgBenchmark.benchmarkpkg("Krylov", script="benchmark/cg_bmark.jl")

# optional: customize plot appearance
using Plots
pyplot()  # recommended!
using PlotThemes
theme(:juno)

common_plot_args = Dict{Symbol, Any}(
  :linewidth => 2,
  :alpha => 0.75,
  :titlefontsize => 8,
  :legendfontsize => 8,
  :xtickfontsize => 6,
  :ytickfontsize => 6,
  :guidefontsize => 8,
)
Plots.default(; common_plot_args...)

# process benchmark results and post gist
p = profile_solvers(results)
posted_gist = to_gist(results, p)
println(posted_gist.html_url)
