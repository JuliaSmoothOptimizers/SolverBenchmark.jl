using BenchmarkTools
using PkgBenchmark
import Plots

function test_pkgbmark()
  results = PkgBenchmark.benchmarkpkg("SolverBenchmark", script=joinpath(@__DIR__, "bmark_suite.jl"))

  stats = bmark_results_to_dataframes(results)
  @info stats
  @test length(keys(stats)) == 2
  @test :lu ∈ keys(stats)
  @test :qr ∈ keys(stats)
  @test size(stats[:lu]) == (10, 5)  # 10 problems x (problem name + 4 PkgBenchmark measures)
  @test size(stats[:qr]) == (10, 5)

  p = profile_solvers(results)
  @test typeof(p) <: Plots.Plot

  costs = [df -> df[:time], df -> df[:memory], df -> df[:gctime] .+ 1, df -> df[:allocations]]
  p = profile_solvers(stats, costs, ["time", "memory", "gctime+1", "allocations"])
  @test typeof(p) <: Plots.Plot

  master = PkgBenchmark.benchmarkpkg("SolverBenchmark", "master", script=joinpath(@__DIR__, "bmark_suite.jl"))
  judgement = PkgBenchmark.judge(results, master)
  stats = judgement_results_to_dataframes(judgement)
  @test length(keys(stats)) == 2
  @test :target ∈ keys(stats)
  @test :baseline ∈ keys(stats)
  @test size(stats[:target]) == (10, 5)
  @test size(stats[:baseline]) == (10, 5)

  p = profile_package(judgement)
  @test typeof(p) <: Plots.Plot

  costs = [df -> df[:time], df -> df[:memory], df -> df[:gctime] .+ 1, df -> df[:allocations]]
  p = profile_solvers(stats, costs, ["time", "memory", "gctime+1", "allocations"])
  @test typeof(p) <: Plots.Plot
end

test_pkgbmark()
