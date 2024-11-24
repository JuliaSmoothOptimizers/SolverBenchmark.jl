using DataFrames
using Logging
using NLPModels, ADNLPModels
using SolverCore
using Base.Threads

import SolverCore.dummy_solver

mutable struct CallableSolver end

function (solver::CallableSolver)(nlp::AbstractNLPModel; kwargs...)
  return GenericExecutionStats(nlp)
end

function bmark_solvers_single_thread(solvers::Dict{Symbol, <:Any}, args...; kwargs...)
  stats = Dict{Symbol, DataFrame}()
  for (name, solver) in solvers
    @info "running solver $name"
    stats[name] = solve_problems(solver, name, args...; kwargs...)
  end
  return stats
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
    stats = solve_problems(dummy_solver, "dummy", problems)
    @test stats isa DataFrame
    stats = solve_problems(dummy_solver, "dummy", problems, reset_problem = false)
    stats = solve_problems(dummy_solver, "dummy", problems, reset_problem = true)

    solve_problems(callable, "callable", problems)

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

  if Threads.nthreads() > 1  # if we have multi_thread
    @testset "Multithread vs Single-Thread Consistency" begin
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
      solvers = Dict(
        :dummy => dummy_solver,
        :callable => callable,
        :dummy_solver_specific =>
          nlp -> dummy_solver(
            nlp,
            callback = (nlp, solver, stats) -> set_solver_specific!(stats, :foo, 1),
          ),
      )

      # Run the single-threaded version
      single_threaded_result = bmark_solvers_single_thread(solvers, problems)
      multithreaded_result = bmark_solvers(solvers, problems)

      # Compare the results
      @test length(single_threaded_result) == length(multithreaded_result)

      for key in keys(single_threaded_result)
        # for (i, row) in enumerate(eachrow(single_threaded_result[key]))
        for i in 1:nrow(single_threaded_result[key])
          @test single_threaded_result[key][i,:status] == multithreaded_result[key][i, :status]
          @test single_threaded_result[key][i,:name] == multithreaded_result[key][i, :name]
          @test single_threaded_result[key][i,:nvar] == multithreaded_result[key][i, :nvar]
          @test single_threaded_result[key][i,:ncon] == multithreaded_result[key][i, :ncon]
          
          @test single_threaded_result[key][i,:objective] ≈ multithreaded_result[key][i, :objective]
          @test single_threaded_result[key][i,:dual_feas] ≈ multithreaded_result[key][i, :dual_feas]
          @test single_threaded_result[key][i,:primal_feas] ≈ multithreaded_result[key][i, :primal_feas]
        end
      end
    end
  end
  @testset "Testing logging" begin
    nlps = [ADNLPModel(x -> sum(x .^ k), ones(2k), name = "Sum of power $k") for k = 2:4]
    push!(
      nlps,
      ADNLPModel(x -> dot(x, x), ones(2), x -> [sum(x) - 1], [0.0], [0.0], name = "linquad"),
    )
    with_logger(ConsoleLogger()) do
      @info "Testing simple logger on `solve_problems`"
      solve_problems(dummy_solver, "dummy", nlps)
      reset!.(nlps)

      @info "Testing logger with specific columns on `solve_problems`"
      solve_problems(
        dummy_solver,
        "dummy",
        nlps,
        colstats = [:name, :nvar, :elapsed_time, :objective, :dual_feas],
      )
      reset!.(nlps)

      @info "Testing logger with hdr_override on `solve_problems`"
      hdr_override = Dict(:dual_feas => "‖∇L(x)‖", :primal_feas => "‖c(x)‖")
      solve_problems(dummy_solver, "dummy", nlps, info_hdr_override = hdr_override)
      reset!.(nlps)
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
        nlp -> dummy_solver(
          nlp,
          callback = (nlp, solver, stats) -> set_solver_specific!(stats, :foo, 1),
        ),
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
