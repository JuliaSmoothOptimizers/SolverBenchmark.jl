using BenchmarkTools
using LibGit2
using PkgBenchmark
import Plots

function test_pkgbmark()
  # When running breakage tests, don't run these tests
  if get(ENV, "CI", nothing) !== nothing &&
     get(ENV, "GITHUB_REPOSITORY", "") != "JuliaSmoothOptimizers/SolverBenchmark.jl"
    return
  end
  # Skip benchmarking tests if the repository has uncommitted changes.
  # PkgBenchmark refuses to benchmark a specific commit when the working tree is dirty.
  try
    git_status = chomp(read(`git status --porcelain`, String))
    if !isempty(git_status)
      @info "Skipping package-benchmark tests because repository is dirty"
      return
    end
  catch e
    @warn "Could not determine git status; proceeding with pkgbmark tests: $e"
  end
  results =
    PkgBenchmark.benchmarkpkg("SolverBenchmark", script = joinpath(@__DIR__, "bmark_suite.jl"))

  stats = bmark_results_to_dataframes(results)
  @info stats
  @test length(keys(stats)) == 2
  @test :lu ∈ keys(stats)
  @test :qr ∈ keys(stats)
  @test size(stats[:lu]) == (10, 5)  # 10 problems x (problem name + 4 PkgBenchmark measures)
  @test size(stats[:qr]) == (10, 5)

  p = profile_solvers(results)
  @test typeof(p) <: Plots.Plot

  costs =
    [df -> df[!, :time], df -> df[!, :memory], df -> df[!, :gctime] .+ 1, df -> df[!, :allocations]]
  p = profile_solvers(stats, costs, ["time", "memory", "gctime+1", "allocations"])
  @test typeof(p) <: Plots.Plot

  repo = LibGit2.GitRepo(joinpath(@__DIR__, ".."))
  LibGit2.lookup_branch(repo, "main") === nothing && LibGit2.branch!(repo, "main", force = true)
  main = PkgBenchmark.benchmarkpkg(
    "SolverBenchmark",
    "main",
    script = joinpath(@__DIR__, "bmark_suite.jl"),
  )
  judgement = PkgBenchmark.judge(results, main)
  stats = judgement_results_to_dataframes(judgement)
  @info stats
  @test length(keys(stats)) == 2
  @test :lu ∈ keys(stats)
  @test :qr ∈ keys(stats)
  for k ∈ keys(stats)
    @test :target ∈ keys(stats[k])
    @test :baseline ∈ keys(stats[k])
  end
  for k ∈ keys(stats)
    for j ∈ keys(stats[k])
      @test size(stats[k][j]) == (10, 5)
    end
  end
  p = profile_package(judgement)
  @test typeof(p) <: Dict{Symbol, Plots.Plot}

  costs =
    [df -> df[!, :time], df -> df[!, :memory], df -> df[!, :gctime] .+ 1, df -> df[!, :allocations]]
  p = profile_solvers(stats[:lu], costs, ["time", "memory", "gctime+1", "allocations"])
  @test typeof(p) <: Plots.Plot
end

test_pkgbmark()
