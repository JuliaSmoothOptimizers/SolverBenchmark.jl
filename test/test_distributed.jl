using Distributed
#THIS NEEDS TO BE TESTED IN DISTRIBUTED SERVER ENVIRONMENT

if nprocs() == 1
    addprocs(2)
end

@everywhere using ADNLPModels, JSOSolvers, NLPModelsIpopt, OptimizationProblems, SolverBenchmark
@everywhere using OptimizationProblems.ADNLPProblems 

@testset "Parallel vs Serial: Real OptimizationProblems" begin
    
    # 1. Setup Data
    probs = OptimizationProblems.meta
    problem_names = probs[(probs.ncon .== 0) .& .!probs.has_bounds .& (5 .<= probs.nvar .<= 100), :name][1:5]
    
    # Function to create fresh generator for each run
    get_problems = () -> (eval(Meta.parse(problem))() for problem ∈ problem_names)

    @everywhere begin
        solvers = Dict(
            :trunk => nlp -> trunk(nlp, atol = 1.0e-4, rtol = 1.0e-5, max_time = 10.0, verbose = 0),
            :ipopt => nlp -> ipopt(nlp, tol = 1.0e-5, max_cpu_time = 10.0, print_level = 0, sb = "no"),
        )
    end
    
    to_skip = ["thurber"]
    skip_fn = prob -> prob.meta.name ∈ to_skip

    # 2. Run Serial
    stats_serial = bmark_solvers(solvers, get_problems(), skipif = skip_fn, parallel=false)

    # 3. Run Parallel
    stats_parallel = bmark_solvers(solvers, get_problems(), skipif = skip_fn, parallel=true)

    # 4. Compare
    for k in keys(solvers)
        df_s = sort(stats_serial[k], :name)
        df_p = sort(stats_parallel[k], :name)

        @test size(df_s) == size(df_p)
        @test df_s.name == df_p.name
        @test df_s.status == df_p.status
        @test isapprox(df_s.objective, df_p.objective, atol=1e-5, nans=true)
    end
end