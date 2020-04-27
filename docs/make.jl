using Documenter, SolverBenchmark

makedocs(
  modules = [SolverBenchmark],
  doctest = true,
  linkcheck = true,
  strict = true,
  format = Documenter.HTML(assets = ["assets/style.css"], prettyurls = get(ENV, "CI", nothing) == "true"),
  sitename = "SolverBenchmark.jl",
  pages = ["Home" => "index.md",
           "Tutorial" => "tutorial.md",
           "API" => "api.md",
           "Reference" => "reference.md",
          ]
)

deploydocs(repo = "github.com/JuliaSmoothOptimizers/SolverBenchmark.jl.git")
