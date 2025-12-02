using Test
using DataFrames
using BenchmarkProfiles
using Plots

# Use the package under test
using SolverBenchmark

# A small capture backend to test that bp_kwargs are forwarded to
# BenchmarkProfiles.performance_profile
struct CaptureBackend <: BenchmarkProfiles.AbstractBackend end

struct CapturedPlot
  labels::Vector{String}
  kwargs::NamedTuple
end

# Extend BenchmarkProfiles.performance_profile for our CaptureBackend
function BenchmarkProfiles.performance_profile(::CaptureBackend, P, labels...; kwargs...)
  CapturedPlot(collect(labels), kwargs)
end

# Intercept Plots.plot when passed our CapturedPlot objects so we can
# inspect the keyword arguments forwarded to the final plot call.
function Plots.plot(ps::CapturedPlot...; kwargs...)
  return (plots = ps, plot_kwargs = kwargs)
end

@testset "profiles: bp_kwargs and plot_kwargs forwarding" begin
  # Build minimal stats: two solvers with simple dataframes
  df1 = DataFrame(a = [1.0, 2.0])
  df2 = DataFrame(a = [2.0, 3.0])
  stats = Dict(:s1 => df1, :s2 => df2)

  costs = [df -> df.a]
  costnames = ["a"]

  # Test bp_kwargs forwarded to backend
  result = profile_solvers(stats, costs, costnames; b = CaptureBackend(), bp_kwargs = Dict(:logscale => false))
  @test typeof(result) == Tuple
  # The inner performance_profile returns CapturedPlot objects stored in result.plots
  plots = result[:plots]
  @test length(plots) >= 1
  first_plot = plots[1]
  @test first_plot.kwargs[:logscale] == false

  # Test plot_kwargs forwarded to final plot call, and that kwargs also work
  result2 = profile_solvers(stats, costs, costnames; b = CaptureBackend(), bp_kwargs = Dict(:logscale => true), plot_kwargs = Dict(:title => "T"), legend = false)
  @test typeof(result2) == Tuple
  @test result2[:plot_kwargs][:title] == "T"
  @test result2[:plot_kwargs][:legend] == false

  # Test both bp_kwargs and plot_kwargs can be used simultaneously without conflict
  result3 = profile_solvers(stats, costs, costnames; b = CaptureBackend(), bp_kwargs = Dict(:foo => 1), plot_kwargs = Dict(:bar => 2), extra = 3)
  @test result3[:plots][1].kwargs[:foo] == 1
  @test result3[:plot_kwargs][:bar] == 2
  @test result3[:plot_kwargs][:extra] == 3
end
