# stdlib imports
using Printf, Random, Test

# dependencies imports
using DataFrames

# test dependencies
using PGFPlotsX, UnicodePlots
using Plots

# this package
using SolverBenchmark

include("data.jl")
include("tables.jl")
include("profiles.jl")
include("pkgbmark.jl")
include("test_bmark.jl")
