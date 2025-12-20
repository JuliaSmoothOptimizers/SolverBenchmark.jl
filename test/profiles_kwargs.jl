using Test
using DataFrames
using SolverBenchmark
using BenchmarkProfiles
using Plots

struct CaptureBackend <: BenchmarkProfiles.AbstractBackend end

struct CapturedPlot
  labels::Vector{String}
  kwargs::Any
end

# Extend BenchmarkProfiles.performance_profile for our CaptureBackend
function BenchmarkProfiles.performance_profile(
  ::CaptureBackend,
  P::Matrix{<:Number},
  labels::Vector{<:AbstractString};
  kwargs...,
)
  labs = string.(labels)
  CapturedPlot(labs, kwargs)
end

function Plots.plot(ps::CapturedPlot...; kwargs...)
  return (plots = ps, plot_kwargs = kwargs)
end

@testset "profiles: bp_kwargs and kwargs forwarding" begin
  df1 = DataFrame(a = [1.0, 2.0])
  df2 = DataFrame(a = [2.0, 3.0])
  stats = Dict(:s1 => df1, :s2 => df2)

  costs = [df -> df.a]
  costnames = ["a"]

  result = profile_solvers(
    stats,
    costs,
    costnames;
    b = CaptureBackend(),
    bp_kwargs = Dict(:logscale => false),
  )
  @test isa(result, NamedTuple)
  # The inner performance_profile returns CapturedPlot objects stored in result.plots
  plots = result[:plots]
  @test length(plots) >= 1
  first_plot = plots[1]
  @test (:logscale in keys(first_plot.kwargs)) && first_plot.kwargs[:logscale] == false

  result2 = profile_solvers(
    stats,
    costs,
    costnames;
    b = CaptureBackend(),
    bp_kwargs = Dict(:logscale => true),
    title = "T",
    legend = false,
  )
  @test isa(result2, NamedTuple)
  @test (:title in keys(result2[:plot_kwargs])) && result2[:plot_kwargs][:title] == "T"
  @test (:legend in keys(result2[:plot_kwargs])) && result2[:plot_kwargs][:legend] == false

  result3 = profile_solvers(
    stats,
    costs,
    costnames;
    b = CaptureBackend(),
    bp_kwargs = Dict(:foo => 1),
    bar = 2,
    extra = 3,
  )
  @test (:foo in keys(result3[:plots][1].kwargs)) && result3[:plots][1].kwargs[:foo] == 1
  @test (:bar in keys(result3[:plot_kwargs])) && result3[:plot_kwargs][:bar] == 2
  @test (:extra in keys(result3[:plot_kwargs])) && result3[:plot_kwargs][:extra] == 3
end
