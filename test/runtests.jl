# stdlib imports
using LinearAlgebra
using Printf
using Random
using Test

# dependencies imports
using DataFrames
using LaTeXStrings

# test dependencies
using OrderedCollections
using PGFPlotsX
using UnicodePlots
using Plots

# this package
using SolverBenchmark

include("data.jl")
include("tables.jl")
include("profiles.jl")
include("pkgbmark.jl")
include("test_bmark.jl")
include("CUTEst_test.jl")
