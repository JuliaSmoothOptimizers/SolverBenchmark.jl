using DataFrames
using Logging
using NLPModels, ADNLPModels
using SolverCore

include("dummy_solver.jl")

mutable struct CallableSolver end

function (solver::CallableSolver)(nlp::AbstractNLPModel; kwargs...)
  return GenericExecutionStats(nlp)
end

function test_bmark()
  @testset "Testing bmark" begin
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
    callable = CallableSolver()
    stats = solve_problems(dummy_solver, problems)
    @test stats isa DataFrame
    stats = solve_problems(dummy_solver, problems, reset_problem = false)
    stats = solve_problems(dummy_solver, problems, reset_problem = true)

    solve_problems(callable, problems)

    solvers = Dict(:dummy => dummy_solver, :callable => callable)
    stats = bmark_solvers(solvers, problems)
    @test stats isa Dict{Symbol, DataFrame}
    for k in keys(solvers)
      @test haskey(stats, k)
    end

    # write stats to file
    filename = tempname()
    save_stats(stats, filename)

    # read stats from file
    stats2 = load_stats(filename)

    # check that they are the same
    for k ∈ keys(stats)
      @test k ∈ keys(stats2)
      @test stats[k] == stats2[k]
    end

    statuses, avgs = quick_summary(stats)

    pretty_stats(stats[:dummy])
  end

  @testset "Testing logging" begin
    nlps = [ADNLPModel(x -> sum(x .^ k), ones(2k), name = "Sum of power $k") for k = 2:4]
    push!(
      nlps,
      ADNLPModel(x -> dot(x, x), ones(2), x -> [sum(x) - 1], [0.0], [0.0], name = "linquad"),
    )
    with_logger(ConsoleLogger()) do
      @info "Testing simple logger on `solve_problems`"
      solve_problems(dummy_solver, nlps)
      reset!.(nlps)

      @info "Testing logger with specific columns on `solve_problems`"
      solve_problems(
        dummy_solver,
        nlps,
        colstats = [:name, :nvar, :elapsed_time, :objective, :dual_feas],
      )
      reset!.(nlps)

      @info "Testing logger with hdr_override on `solve_problems`"
      hdr_override = Dict(:dual_feas => "‖∇L(x)‖", :primal_feas => "‖c(x)‖")
      solve_problems(dummy_solver, nlps, info_hdr_override = hdr_override)
      reset!.(nlps)
    end
  end
end

test_bmark()
