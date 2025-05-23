using DataFrames
using Logging
using NLPModels, ADNLPModels
using SolverCore

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
    stats = solve_problems(dummy, "dummy", problems)
    @test stats isa DataFrame
    stats = solve_problems(dummy, "dummy", problems, reset_problem = false)
    stats = solve_problems(dummy, "dummy", problems, reset_problem = true)

    solve_problems(callable, "callable", problems)

    solvers = Dict(:dummy => dummy, :callable => callable)
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
      solve_problems(dummy, "dummy", nlps)
      NLPModels.reset!.(nlps)

      @info "Testing logger with specific columns on `solve_problems`"
      solve_problems(
        dummy,
        "dummy",
        nlps,
        colstats = [:name, :nvar, :elapsed_time, :objective, :dual_feas],
      )
      NLPModels.reset!.(nlps)

      @info "Testing logger with hdr_override on `solve_problems`"
      hdr_override = Dict(:dual_feas => "‖∇L(x)‖", :primal_feas => "‖c(x)‖")
      solve_problems(dummy, "dummy", nlps, info_hdr_override = hdr_override)
      NLPModels.reset!.(nlps)
    end
  end

  @testset "Test skips and exceptions" begin
    problems = [
      ADNLPModel(x -> sum(x .^ 2), ones(2), name = "Quadratic"),
      ADNLPModel(
        x -> (x[1] - 1)^2 + 4 * (x[2] - x[1]^2)^2,
        ones(2),
        x -> [x[1]^2 + x[2]^2 - 1],
        [0.0],
        [0.0],
        name = "Cons Rosen",
      ),
      ADNLPModel(
        x -> sum(x .^ 2),
        ones(2),
        x -> [sum(x) - 1],
        [0.0],
        [0.0],
        name = "Cons quadratic",
      ),
    ]

    solvers = Dict(
      :dummy_solver_specific =>
        nlp ->
          dummy(nlp, callback = (nlp, solver, stats) -> set_solver_specific!(stats, :foo, 1)),
    )
    stats = bmark_solvers(solvers, problems)

    @test stats[:dummy_solver_specific][1, :status] == :exception
    @test stats[:dummy_solver_specific][2, :status] == :first_order
    @test stats[:dummy_solver_specific][3, :status] == :exception
    @test size(stats[:dummy_solver_specific], 1) == 3

    stats =
      bmark_solvers(solvers, problems, prune = false, skipif = problem -> problem.meta.ncon == 0)

    @test stats[:dummy_solver_specific][1, :extrainfo] == "skipped"
    @test stats[:dummy_solver_specific][2, :status] == :first_order
    @test stats[:dummy_solver_specific][3, :status] == :exception
    @test size(stats[:dummy_solver_specific], 1) == 3
  end
end

test_bmark()
