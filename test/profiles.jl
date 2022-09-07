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
