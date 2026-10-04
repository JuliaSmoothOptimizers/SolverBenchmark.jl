function test_profiles()
  stats = get_stats_data() # from data.jl

  @info "Generating performance profiles"
  @info "Cost: t"
  unicodeplots()
  p = performance_profile(
    stats,
    df -> df.t,
    b = SolverBenchmark.BenchmarkProfiles.UnicodePlotsBackend(),
  )
  p = profile_solvers(stats, [df -> df.t, df -> df.iter], ["Time", "Iterations"])
  @test size(p.layout.grid) == (4, 2)
  p = profile_solvers(stats, [df -> df.t, df -> df.iter], ["Time", "Iterations"], rotate = true)
  @test size(p.layout.grid) == (2, 4)

  # bp_kwargs forwards keyword arguments to BenchmarkProfiles.performance_profile
  p = profile_solvers(
    stats,
    [df -> df.t, df -> df.iter],
    ["Time", "Iterations"],
    bp_kwargs = Dict{Symbol, Any}(:logscale => false),
  )
  @test size(p.layout.grid) == (4, 2)

  # bp_kwargs entries take precedence over the internal defaults (e.g., legend)
  # without raising a duplicate-keyword error
  p = profile_solvers(
    stats,
    [df -> df.t, df -> df.iter],
    ["Time", "Iterations"],
    bp_kwargs = Dict{Symbol, Any}(:legend => :topleft, :palette => :viridis),
  )
  @test size(p.layout.grid) == (4, 2)
  if !Sys.isfreebsd()
    pgfplotsx()
    p = performance_profile(
      stats,
      df -> df.t,
      b = SolverBenchmark.BenchmarkProfiles.PGFPlotsXBackend(),
    )
  end
  nothing
end

test_profiles()
