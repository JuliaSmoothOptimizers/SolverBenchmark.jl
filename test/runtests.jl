# stdlib imports
using Printf, Random, Test

# dependencies imports
using DataFrames

# test dependencies
using Plots

# JSO
using SolverCore, OptSolver

# this package
using SolverBenchmark

include("data.jl")
include("tables.jl")
include("profiles.jl")
include("pkgbmark.jl")
include("test_bmark.jl")
