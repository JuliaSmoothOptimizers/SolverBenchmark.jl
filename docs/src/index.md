# [SolverBenchmark.jl documentation](@id Home)

This package provides general tools for benchmarking solvers, focusing on a few
guidelines:
- The output of a solver's run on a suite of problems is a `DataFrame`, where each row
  is a different problem.
  - Since naming issues may arise (e.g., same problem with different number of
    variables), there must be an ID column;
- The collection of two or more solver runs (`DataFrame`s), is a
  `Dict{Symbol,DataFrame}`, where each key is a solver;

This package is developed focusing on
[Krylov.jl](https://github.com/JuliaSmoothOptimizers/Krylov.jl) and
[JSOSolvers.jl](https://github.com/JuliaSmoothOptimizers/JSOSolvers.jl), but they should be
general enough to be used in other places.

## Bug reports and discussions

If you think you found a bug, feel free to open an [issue](https://github.com/JuliaSmoothOptimizers/SolverBenchmark.jl/issues).
Focused suggestions and requests can also be opened as issues. Before opening a pull request, start an issue or a discussion on the topic, please.

If you want to ask a question not suited for a bug report, feel free to start a discussion [here](https://github.com/JuliaSmoothOptimizers/Organization/discussions). This forum is for general discussion about this repository and the [JuliaSmoothOptimizers](https://github.com/JuliaSmoothOptimizers) organization, so questions about any of our packages are welcome.
