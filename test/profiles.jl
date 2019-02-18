function test_profiles()
  example_folder = joinpath(@__DIR__, "example")
  stats = get_stats_data() # from data.jl

  @info "Generating performance profiles"
  @info "Cost: t"
  gr()
  p = performance_profile(stats, df->df.t);
  Plots.pdf("$example_folder/profile1")
  p = profile_solvers(stats, [df->df.t, df->df.iter], ["Time", "Iterations"])
  Plots.pdf("$example_folder/profile2")
  nothing
end

test_profiles()
