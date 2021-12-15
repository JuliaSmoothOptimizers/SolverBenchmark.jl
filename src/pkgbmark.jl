import BenchmarkTools
import GitHub
import JSON
import PkgBenchmark

export bmark_results_to_dataframes, judgement_results_to_dataframes, profile_package, to_gist

"""
    stats = bmark_results_to_dataframes(results)

Convert `PkgBenchmark` results to a dictionary of `DataFrame`s.
The benchmark SUITE should have been constructed in
the form

    SUITE[solver][case] = ...

where `solver` will be recorded as one of the solvers
to be compared in the DataFrame and case is a test
case. For example:

    SUITE["CG"]["BCSSTK09"] = @benchmarkable ...
    SUITE["LBFGS"]["ROSENBR"] = @benchmarkable ...

Inputs:
- `results::BenchmarkResults`: the result of `PkgBenchmark.benchmarkpkg`

Output:
- `stats::Dict{Symbol,DataFrame}`: a dictionary of `DataFrame`s containing the
    benchmark results per solver.
"""
function bmark_results_to_dataframes(results::PkgBenchmark.BenchmarkResults)
  entries = BenchmarkTools.leaves(PkgBenchmark.benchmarkgroup(results))
  entries = entries[sortperm(map(x -> string(first(x)), entries))]
  solvers = unique(map(pair -> pair[1][1], entries))
  names = [:name, :time, :memory, :gctime, :allocations]
  types = [String, Float64, Float64, Float64, Int]

  stats = Dict{Symbol, DataFrame}()
  for solver in solvers
    stats[Symbol(solver)] = DataFrame(names .=> [T[] for T in types])
  end

  for entry in entries
    case, trial = entry
    name = case[end]
    solver = Symbol(case[1])
    time = BenchmarkTools.time(trial)
    mem = BenchmarkTools.memory(trial)
    gctime = BenchmarkTools.gctime(trial)
    allocs = BenchmarkTools.allocs(trial)
    push!(stats[solver], [name, time, mem, gctime, allocs])
  end

  stats
end

"""
    stats = judgement_results_to_dataframes(judgement)

Convert `BenchmarkJudgement` results to a dictionary of `DataFrame`s.

Inputs:
- `judgement::BenchmarkJudgement`: the result of, e.g.,

      commit = benchmarkpkg(mypkg)  # benchmark a commit or pull request
      main = benchmarkpkg(mypkg, "main")  # baseline benchmark
      judgement = judge(commit, main)

Output:
- `stats::Dict{Symbol,Dict{Symbol,DataFrame}}`: a dictionary of
    `Dict{Symbol,DataFrame}`s containing the target and baseline benchmark results.
    The elements of this dictionary are the same as those returned by
    `bmark_results_to_dataframes(main)` and `bmark_results_to_dataframes(commit)`.
"""
function judgement_results_to_dataframes(judgement::PkgBenchmark.BenchmarkJudgement)
  target_stats = bmark_results_to_dataframes(judgement.target_results)
  baseline_stats = bmark_results_to_dataframes(judgement.baseline_results)
  Dict{Symbol, Dict{Symbol, DataFrame}}(
    k => Dict{Symbol, DataFrame}(:target => target_stats[k], :baseline => baseline_stats[k]) for
    k ∈ keys(target_stats)
  )
end

"""
    p = profile_solvers(results)

Produce performance profiles based on `PkgBenchmark.benchmarkpkg` results.

Inputs:
- `results::BenchmarkResults`: the result of `PkgBenchmark.benchmarkpkg`.
"""
function profile_solvers(results::PkgBenchmark.BenchmarkResults)
  # guard against zero gctimes
  costs =
    [df -> df[!, :time], df -> df[!, :memory], df -> df[!, :gctime] .+ 1, df -> df[!, :allocations]]
  profile_solvers(
    bmark_results_to_dataframes(results),
    costs,
    ["time", "memory", "gctime+1", "allocations"],
  )
end

"""
    p = profile_package(judgement)

Produce performance profiles based on `PkgBenchmark.BenchmarkJudgement` results.

Inputs:
- `judgement::BenchmarkJudgement`: the result of, e.g.,

      commit = benchmarkpkg(mypkg)  # benchmark a commit or pull request
      main = benchmarkpkg(mypkg, "main")  # baseline benchmark
      judgement = judge(commit, main)

"""
function profile_package(judgement::PkgBenchmark.BenchmarkJudgement)
  # guard against zero gctimes
  costs =
    [df -> df[!, :time], df -> df[!, :memory], df -> df[!, :gctime] .+ 1, df -> df[!, :allocations]]
  judgement_dataframes = judgement_results_to_dataframes(judgement)
  Dict{Symbol, Plots.Plot}(
    k => profile_solvers(
      judgement_dataframes[k],
      costs,
      ["time", "memory", "gctime+1", "allocations"],
    ) for k ∈ keys(judgement_dataframes)
  )
end

"""
    posted_gist = to_gist(results, p)

Create and post a gist with the benchmark results and performance profiles.

Inputs:
- `results::BenchmarkResults`: the result of `PkgBenchmark.benchmarkpkg`
- `p`:: the result of `profile_solvers`.

Output:
- the return value of GitHub.jl's `create_gist`.
"""
function to_gist(results::PkgBenchmark.BenchmarkResults, p)
  filename = tempname()
  svgfilename = "$(filename).svg"
  savefig(p, svgfilename)
  svgfilecontents = escape_string(read(svgfilename, String))

  gist_json = JSON.parse(
    """
    {
      "description": "Benchmarks uploaded by SolverBenchmark.jl",
      "public": true,
      "files": {
          "bmark.md": {
            "content": "$(escape_string(sprint(PkgBenchmark.export_markdown, results; context=stdout)))"
          },
          "bmark.svg": {
            "content": "$(svgfilecontents)"
          }
      }
    }
    """,
  )

  # Need to add GITHUB_AUTH to your .bashrc
  myauth = GitHub.authenticate(ENV["GITHUB_AUTH"])
  GitHub.create_gist(params = gist_json, auth = myauth)
end

"""
    posted_gist = to_gist(results)

Create and post a gist with the benchmark results and performance profiles.

Inputs:
- `results::BenchmarkResults`: the result of `PkgBenchmark.benchmarkpkg`

Output:
- the return value of GitHub.jl's `create_gist`.
"""
to_gist(results) = to_gist(results, profile_solvers(results))
