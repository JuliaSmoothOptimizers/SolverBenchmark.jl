# [SolverBenchmark.jl documentation](@id Home)

This package provides general tools for benchmarking solvers, focusing on a few
guidelines:
- The output of a solver's run on a suite of problems is a `DataFrame`, where each row
  is a different problem.
  - Since naming issues may arise (e.g., same problem with different number of
    variables), there must be an ID column;
- The collection of two or more solver runs (`DataFrame`s), is a
  `Dict{Symbol,DataFrame}`, where each key is a solver;

Package objectives:
- Print to latex.
- Print to pretty markdown table.
- Produce performance profiles.

This package is developed focusing on
[Krylov.jl](https://github.com/JuliaSmoothOptimizers/Krylov.jl) and
[Optimize.jl](https://github.com/JuliaSmoothOptimizers/Optimize.jl), but they should be
general enough to be used in other places.

