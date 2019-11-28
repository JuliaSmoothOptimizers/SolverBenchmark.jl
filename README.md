# SolverBenchmark.jl

[![Build Status](https://travis-ci.org/JuliaSmoothOptimizers/SolverBenchmark.jl.svg?branch=master)](https://travis-ci.org/JuliaSmoothOptimizers/SolverBenchmark.jl)
[![Build status](https://ci.appveyor.com/api/projects/status/s3213w0k9s9d45ro?svg=true)](https://ci.appveyor.com/project/dpo/solverbenchmark-jl)
[![Build Status](https://api.cirrus-ci.com/github/JuliaSmoothOptimizers/SolverBenchmark.jl.svg)](https://cirrus-ci.com/github/JuliaSmoothOptimizers/SolverBenchmark.jl)
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

This package is developed focusing on
[Krylov.jl](https://github.com/JuliaSmoothOptimizers/Krylov.jl) and
[JSOSolvers.jl](https://github.com/JuliaSmoothOptimizers/JSOSolvers.jl), but is
sufficiently general to be used in other places.

## Example

Obs: See the [assets](assets) folder for the complete code, or the [docs](https://JuliaSmoothOptimizers.github.io/SolverBenchmark.jl/latest) for a more detailed example.

### Example table of a single `DataFrame`

`markdown_table(io, df)`

```
|    flag |    name |     f(x) |     time |  iter |
|---------|---------|----------|----------|-------|
| failure | prob001 | -6.9e-01 |  6.2e+01 |    70 |
| failure | prob002 | -7.6e-01 |  3.5e+02 |    10 |
| success | prob003 |  4.0e-01 |  7.7e+02 |    10 |
| success | prob004 |  8.1e-01 |  4.3e+01 |    80 |
| success | prob005 | -3.5e-01 |  2.7e+02 |    30 |
| success | prob006 | -1.9e-01 |  6.7e+01 |    80 |
| success | prob007 | -1.6e+00 |  1.6e+02 |    60 |
| success | prob008 | -2.5e+00 |  6.1e+02 |    40 |
| success | prob009 |  2.3e+00 |  1.4e+02 |    40 |
| failure | prob010 |  2.2e-01 |  8.4e+02 |    50 |
```

`latex_table(io, df)`

![](assets/alpha.svg)

### Example table of a joined `DataFrame`

```
df = join(stats, [:status, :f, :t], ...)
markdown_table(io, df)
```

```
|    id |    name | flag_alpha |  f_alpha |  t_alpha | flag_beta |   f_beta |   t_beta | flag_gamma |  f_gamma |  t_gamma |
|-------|---------|------------|----------|----------|-----------|----------|----------|------------|----------|----------|
|     1 | prob001 |    failure | -6.9e-01 |  6.2e+01 |   success | -1.1e+00 |  1.8e+02 |    success |  6.3e-02 |  3.3e+01 |
|     2 | prob002 |    failure | -7.6e-01 |  3.5e+02 |   failure |  8.2e-01 |  8.0e+01 |    success |  1.2e-01 |  6.9e+02 |
|     3 | prob003 |    success |  4.0e-01 |  7.7e+02 |   success |  1.5e-01 |  6.8e+02 |    success |  2.7e+00 |  8.4e+02 |
|     4 | prob004 |    success |  8.1e-01 |  4.3e+01 |   failure | -3.3e-01 |  9.3e+02 |    failure | -6.9e-01 |  1.9e+02 |
|     5 | prob005 |    success | -3.5e-01 |  2.7e+02 |   failure |  1.4e+00 |  9.7e+02 |    failure | -5.5e-02 |  1.6e+02 |
|     6 | prob006 |    success | -1.9e-01 |  6.7e+01 |   success | -4.4e-01 |  6.5e+02 |    success |  4.2e-01 |  9.0e+02 |
|     7 | prob007 |    success | -1.6e+00 |  1.6e+02 |   success |  1.1e+00 |  6.0e+02 |    success | -1.4e+00 |  9.5e+01 |
|     8 | prob008 |    success | -2.5e+00 |  6.1e+02 |   success | -2.5e-01 |  4.8e+02 |    failure | -4.5e-01 |  7.8e+02 |
|     9 | prob009 |    success |  2.3e+00 |  1.4e+02 |   failure |  2.9e-01 |  6.3e+01 |    failure | -8.8e-01 |  8.7e+02 |
|    10 | prob010 |    failure |  2.2e-01 |  8.4e+02 |   success | -3.5e+00 |  4.7e+02 |    success |  1.1e+00 |  8.4e+02 |
```

`latex_table(io, df)`

![](assets/joined.svg)

### Example profile

`p = performance_profile(stats, df->df.t)`

![](assets/profile1.svg)

### Example profile-wall

`p = profile_solvers(stats, costs, titles)`

![](assets/profile2.svg)
