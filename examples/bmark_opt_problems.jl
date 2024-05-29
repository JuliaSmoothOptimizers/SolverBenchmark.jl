using JLD2, Plots
using ADNLPModels,
  JSOSolvers,
  NLPModelsIpopt,
  OptimizationProblems,
  OptimizationProblems.ADNLPProblems,
  SolverBenchmark

# define problems
probs = OptimizationProblems.meta
problem_names = probs[(probs.ncon .== 0) .& .!probs.has_bounds .& (5 .<= probs.nvar .<= 100), :name]
problems = (eval(Meta.parse(problem))() for problem ∈ problem_names)

# define solvers
solvers = Dict(
  :trunk => nlp -> trunk(nlp, atol = 1.0e-4, rtol = 1.0e-5, max_time = 10.0, verbose = 0),
  :ipopt => nlp -> ipopt(nlp, tol = 1.0e-5, max_cpu_time = 10.0, print_level = 0, sb = "no"),
)

# solve problems, but skip one of our choice
to_skip = ["thurber"]
stats = bmark_solvers(solvers, problems, skipif = prob -> prob.meta.name ∈ to_skip)

# save DataFrame for later
# see JLD2 documentation
@save "stats_opt_problems.jld2" stats

# plot time profile
performance_profile(stats, df -> df.neval_obj)
