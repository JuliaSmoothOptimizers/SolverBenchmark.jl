using JLD2, Plots
using CUTEst, JSOSolvers, NLPModelsIpopt, SolverBenchmark

# define problems
# for CUTEst models, define list of models as an iterator to avoid materializing all models at once
problem_names = CUTEst.select_sif_problems(max_con = 0, min_var = 50, max_var = 80, only_free_var = true)
problems = (CUTEstModel(p) for p in problem_names)

# define solvers
solvers = Dict(
  :trunk => nlp -> trunk(nlp, atol = 1.0e-4, rtol = 1.0e-5, max_time = 10.0, verbose = 0),
  :ipopt => nlp -> ipopt(nlp, tol = 1.0e-5, max_cpu_time = 10.0, print_level = 0, sb = "no"),
)

# solve problems, but skip one of our choice
to_skip = ["DMN37142LS"]
stats = bmark_solvers(solvers, problems, skipif = prob -> prob.meta.name ∈ to_skip)

# save DataFrame for later
# see JLD2 documentation
@save "stats_cutest.jld2" stats

# plot time profile
performance_profile(stats, df -> df.neval_obj)
