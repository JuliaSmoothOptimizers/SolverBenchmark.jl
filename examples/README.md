# Example benchmark scripts

This folder contains example benchmark scripts on problems from various sources:

1. the CUTEst collection (see [CUTEst.jl](https://github.com/JuliaSmoothOptimizers/CUTEst.jl))
2. problems in [AMPL](https://ampl.com) format, read with [AmplNLReader.jl](https://github.com/JuliaSmoothOptimizers/AmplNLReader.jl)
3. problems in pure Julia from [OptimizationProblems.jl](https://github.com/JuliaSmoothOptimizers/OptimizationProblems.jl)
4. problems modeled with JuMP from [OptimizationProblems.jl](https://github.com/JuliaSmoothOptimizers/OptimizationProblems.jl) and read with [NLPModelsJuMP.jl](https://github.com/JuliaSmoothOptimizers/NLPModelsJuMP.jl).

Activate the `examples` folder as a Julia environment and `include()` one of the scripts to test.
Each script should produce

1. a plot window with a performance profile
2. a `jld2` file storing a dictionary of `DataFrames`, each containing the complete results of one of the solvers. Should the data be examined further at a later time, it is simpler to load the `jld2` file than to re-run the benchmarks.

Happy benchmarking!

