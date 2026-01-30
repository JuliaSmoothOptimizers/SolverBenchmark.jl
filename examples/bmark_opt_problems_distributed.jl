using Distributed

# 1. Setup Workers (One per solver is ideal, or use available cores)
# We add workers if they aren't already there
if nprocs() == 1
    addprocs(Sys.CPU_THREADS - 2) 
end

# 2. Load packages on ALL workers
@everywhere begin
    using ADNLPModels
    using JSOSolvers
    using NLPModelsIpopt
    using OptimizationProblems
    using OptimizationProblems.ADNLPProblems
    using SolverBenchmark
end

# These are only needed on the main process for saving/plotting
using JLD2, Plots

# define problems
# NOTE: We keep this as a Generator. 
# Because we are using "Parallel by Solver", the Worker will iterate this generator.
# The instantiation '()' happens ON THE WORKER, which is memory-safe.
probs = OptimizationProblems.meta
problem_names = probs[(probs.ncon .== 0) .& .!probs.has_bounds .& (5 .<= probs.nvar .<= 100), :name]
problems = (eval(Meta.parse(problem))() for problem ∈ problem_names)

# define solvers
# NOTE: Must be defined @everywhere so workers know what ':trunk' and ':ipopt' do.
@everywhere begin
    solvers = Dict(
      :trunk => nlp -> trunk(nlp, atol = 1.0e-4, rtol = 1.0e-5, max_time = 10.0, verbose = 0),
      :ipopt => nlp -> ipopt(nlp, tol = 1.0e-5, max_cpu_time = 10.0, print_level = 0, sb = "no"),
    )
end

# solve problems, but skip one of our choice
to_skip = ["thurber"]

# 3. Run with parallel=true
stats = bmark_solvers(
    solvers, 
    problems, 
    skipif = prob -> prob.meta.name ∈ to_skip,
    parallel = true # <--- NEW FLAG
)

# save DataFrame for later
@save "stats_opt_problems.jld2" stats

# plot time profile
performance_profile(stats, df -> df.neval_obj)