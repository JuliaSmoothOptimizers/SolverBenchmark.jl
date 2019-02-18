# SolverBenchmark.jl

[![Build Status](https://travis-ci.org/JuliaSmoothOptimizers/SolverBenchmark.jl.svg?branch=master)](https://travis-ci.org/JuliaSmoothOptimizers/SolverBenchmark.jl)
[![Build status](https://ci.appveyor.com/api/projects/status/s3213w0k9s9d45ro?svg=true)](https://ci.appveyor.com/project/dpo/solverbenchmark-jl)
[![](https://img.shields.io/badge/docs-latest-3f51b5.svg)](https://JuliaSmoothOptimizers.github.io/SolverBenchmark.jl/latest)
[![Coverage Status](https://coveralls.io/repos/github/JuliaSmoothOptimizers/SolverBenchmark.jl/badge.svg?branch=master)](https://coveralls.io/github/JuliaSmoothOptimizers/SolverBenchmark.jl?branch=master)

This package provides general tools for benchmarking solvers, focusing on the following
guidelines:
- The output of a solver's run on a suite of problems is a `DataFrame`, where each row
  is a different problem.
  - Since naming issues may arise (e.g., same problem with different number of
    variables), there must be an ID column;
- The collection of two or more solver runs (`DataFrame`s), is a
  `Dict{Symbol,DataFrame}`, where each key is a solver;

Package objectives:
- [X] Print to latex (WIP in Optimize);
- [X] Print to beautiful markdown table;
- [X] Produce performance profiles.

This package is developed focusing on
[Krylov.jl](https://github.com/JuliaSmoothOptimizers/Krylov.jl) and
[Optimize.jl](https://github.com/JuliaSmoothOptimizers/Optimize.jl), but is
sufficiently general to be used in other places.
