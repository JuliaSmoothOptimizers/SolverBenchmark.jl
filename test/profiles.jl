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

  @info "Exporting perfomance profiles"
  filename = "profiles"
  export_profile_solvers_data(stats,[df -> df.t, df -> df.iter],["Time", "Iterations"],"profiles")
  @test isfile(filename * ".csv")
  rm(filename * ".csv")
  export_profile_solvers_data(stats,[df -> df.t, df -> df.iter],["Time", "Iterations"],"profiles";header=[["x" for _ in 1:6] for _ in 1:2])
  @test isfile(filename * ".csv")
  rm(filename * ".csv")

  export_profile_solvers_data(stats,[df -> df.t, df -> df.iter],["Time", "Iterations"],"profiles";one_file=false)
  @test isfile(filename * "_Time.csv")
  @test isfile(filename * "_Iterations.csv")
  rm(filename * "_Time.csv")
  rm(filename * "_Iterations.csv")
  export_profile_solvers_data(stats,[df -> df.t, df -> df.iter],["Time", "Iterations"],"profiles";one_file=false,header=[["x" for _ in 1:6] for _ in 1:2])
  @test isfile(filename * "_Time.csv")
  @test isfile(filename * "_Iterations.csv")
  rm(filename * "_Time.csv")
  rm(filename * "_Iterations.csv")

  nothing
end

test_profiles()
