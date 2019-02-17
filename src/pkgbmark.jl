import BenchmarkTools
import GitHub
import JSON
import PkgBenchmark

export bmark_results_to_dataframes, to_gist

"""
    stats = bmark_results_to_dataframes(results)

Convert `PkgBenchmark` results to a dictionary of `DataFrame`s.

Inputs:
- `results::BenchmarkResults`: the result of `PkgBenchmark.benchmarkpkg()`

Output:
- `stats::Dict{Symbol,DataFrame}`: a dictionary of `DataFrame`s containing the
    benchmark results per solver.
"""
function bmark_results_to_dataframes(results::PkgBenchmark.BenchmarkResults)
  entries = BenchmarkTools.leaves(PkgBenchmark.benchmarkgroup(results))
  entries = entries[sortperm(map(x -> string(first(x)), entries))]
  solvers = unique(map(pair -> pair[1][end], entries))
  names = [:name, :time, :memory, :gctime, :allocations]
  types = [String, Float64, Float64, Float64, Int]

  stats = Dict{Symbol, DataFrame}()
  for solver in solvers
    stats[Symbol(solver)] = DataFrame(types, names, 0)
  end

  for entry in entries
    case, trial = entry
    name = case[end-1]
    solver = Symbol(case[end])
    time = BenchmarkTools.time(trial)
    mem = BenchmarkTools.memory(trial)
    gctime = BenchmarkTools.gctime(trial)
    allocs = BenchmarkTools.allocs(trial)
    push!(stats[solver], [name, time, mem, gctime, allocs])
  end

  stats
end

"""
    p = profile_solvers(results)

Produce performance profiles based on `PkgBenchmark.benchmarkpkg` results.

Inputs:
- `results::BenchmarkResults`: the result of `PkgBenchmark.benchmarkpkg()`.
"""
function profile_solvers(results::PkgBenchmark.BenchmarkResults)
  # guard against zero gctimes
  costs = [df -> df[:time], df -> df[:memory], df -> df[:gctime] .+ 1, df -> df[:allocations]]
  profile_solvers(bmark_results_to_dataframes(results), costs, ["time", "memory", "gctime+1", "allocations"])
end

"""
    posted_gist = to_gist(results, p)

Create and post a gist with the benchmark results and performance profiles.

Inputs:
- `results::BenchmarkResults`: the result of `PkgBenchmark.benchmarkpkg()`
- `p`:: the result of `profile_solvers()`.

Output:
- the return value of GitHub.jl's `create_gist()`.
"""
function to_gist(results::PkgBenchmark.BenchmarkResults, p)
  filename = tempname()
  svgfilename = "$(filename).svg"
  savefig(p, svgfilename)
  svgfilecontents = escape_string(read(svgfilename, String))

  gist_json = JSON.parse(
  """
  {
    "description": "A benchmark for Krylov repository",
    "public": true,
    "files": {
        "bmark.md.md": {
          "content": "$(escape_string(sprint(export_markdown, results)))"
        },
        "bmark.svg": {
          "content": "$(svgfilecontents)"
        }
    }
  }
  """)

  # Need to add GITHUB_AUTH to your .bashrc
  myauth = GitHub.authenticate(ENV["GITHUB_AUTH"])
  GitHub.create_gist(params = gist_json, auth = myauth)
end

"""
    posted_gist = to_gist(results)

Create and post a gist with the benchmark results and performance profiles.

Inputs:
- `results::BenchmarkResults`: the result of `PkgBenchmark.benchmarkpkg()`

Output:
- the return value of GitHub.jl's `create_gist()`.
"""
to_gist(results) = to_gist(results, profile_solvers(results))
