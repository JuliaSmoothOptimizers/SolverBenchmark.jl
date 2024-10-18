using Test
using DataFrames
using Logging
using NLPModels, ADNLPModels
using SolverCore

import SolverCore.dummy_solver

# Define a mock callable solver
mutable struct CallableSolver end

function (solver::CallableSolver)(nlp::AbstractNLPModel; kwargs...)
  return GenericExecutionStats(nlp)
end

# Unit test for bmark_solvers_parallel
function test_bmark_parallel()
  @testset "Testing bmark_solvers_parallel" begin
    # Define some test problems
    problems = [
      ADNLPModel(x -> sum(x .^ 2), ones(2), name = "Quadratic"),
      ADNLPModel(
        x -> sum(x .^ 2),
        ones(2),
        x -> [sum(x) - 1],
        [0.0],
        [0.0],
        name = "Cons quadratic",
      ),
      ADNLPModel(
        x -> (x[1] - 1)^2 + 4 * (x[2] - x[1]^2)^2,
        ones(2),
        x -> [x[1]^2 + x[2]^2 - 1],
        [0.0],
        [0.0],
        name = "Cons Rosen",
      ),
    ]

    # Mock solvers
    callable = CallableSolver()
    solvers = Dict(:dummy => dummy_solver, :callable => callable)

    # Run parallel solvers benchmark
    stats = bmark_solvers_parallel(solvers, problems)

    # Validate results
    @test stats isa Dict{Symbol, DataFrame}
    @test length(stats) == length(solvers)
    for k in keys(solvers)
      @test haskey(stats, k)
      @test stats[k] isa DataFrame
    end

    # Write results to a temporary file
    filename = tempname()
    save_stats(stats, filename)

    # Load results from the file and validate
    stats2 = load_stats(filename)
    @test stats2 isa Dict{Symbol, DataFrame}
    for k ∈ keys(stats)
      @test k ∈ keys(stats2)
      @test stats[k] == stats2[k]
    end

    # Quick summary and other tests
    statuses, avgs = quick_summary(stats)
    pretty_stats(stats[:dummy])
  end

  @testset "Testing logging in parallel" begin
    # Test logging with solve_problems in parallel
    nlps = [ADNLPModel(x -> sum(x .^ k), ones(2k), name = "Sum of power $k") for k = 2:4]
    push!(
      nlps,
      ADNLPModel(x -> dot(x, x), ones(2), x -> [sum(x) - 1], [0.0], [0.0], name = "linquad"),
    )
    
    with_logger(ConsoleLogger()) do
      @info "Testing simple logger with bmark_solvers_parallel"
      stats = bmark_solvers_parallel(solvers, nlps)
      reset!.(nlps)

      @info "Testing logger with specific columns on bmark_solvers_parallel"
      stats = bmark_solvers_parallel(solvers, nlps, colstats = [:name, :nvar, :elapsed_time, :objective, :dual_feas])
      reset!.(nlps)

      @info "Testing logger with hdr_override on bmark_solvers_parallel"
      hdr_override = Dict(:dual_feas => "‖∇L(x)‖", :primal_feas => "‖c(x)‖")
      stats = bmark_solvers_parallel(solvers, nlps, info_hdr_override = hdr_override)
      reset!.(nlps)
    end
  end
end

# Run the test
test_bmark_parallel()
