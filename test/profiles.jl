function test_profiles()
  example_folder = joinpath(@__DIR__, "example")
  stats = get_stats_data() # from data.jl

  @info "Generating performance profiles"
  @info "Cost: t"
  gr()
  p = performance_profile(stats, df->df.t);
  Plots.pdf("$example_folder/profile1")
  nothing
end

test_profiles()
