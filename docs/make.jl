using Documenter, SolverBenchmark

makedocs(
  modules = [SolverBenchmark],
  checkdocs = :exports,
  doctest = true,
  linkcheck = true,
  format = Documenter.HTML(
    assets = ["assets/style.css"],
    prettyurls = get(ENV, "CI", nothing) == "true",
  ),
  sitename = "SolverBenchmark.jl",
  pages = ["Home" => "index.md", "Reference" => "reference.md"],
)

deploydocs(
  repo = "github.com/JuliaSmoothOptimizers/SolverBenchmark.jl.git",
  push_preview = true,
  devbranch = "main",
)
