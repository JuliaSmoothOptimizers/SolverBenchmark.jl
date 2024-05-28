using JLD2, Plots
using AmplNLReader, Percival, NLPModelsIpopt, SolverBenchmark

# define problems
problem_names = readdir(joinpath(@__DIR__, "ampl"))
problems = (AmplModel(joinpath(@__DIR__, "ampl", p)) for p in problem_names)

# define solvers
solvers = Dict(
  :percival => nlp -> percival(nlp, atol = 1.0e-4, rtol = 1.0e-5, max_time = 10.0, verbose = 0),
  :ipopt => nlp -> ipopt(nlp, tol = 1.0e-5, max_cpu_time = 10.0, print_level = 0, sb = "no"),
)

# solve problems, but skip one of our choice
to_skip = ["hs6max"]
stats = bmark_solvers(solvers, problems, skipif = prob -> basename(prob.meta.name) ∈ to_skip)

# save DataFrame for later
# see JLD2 documentation
@save "stats_ampl.jld2" stats

# plot time profile
performance_profile(stats, df -> df.neval_obj)
