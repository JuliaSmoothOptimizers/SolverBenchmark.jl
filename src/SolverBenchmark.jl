module SolverBenchmark

# stdlib impots
using Printf

# dependencies imports
using DataFrames
using PrettyTables

# Tables
include("formatting.jl")
include("latex_tables.jl")
include("markdown_tables.jl")
include("join.jl")

# Profiles
include("profiles.jl")

# PkgBenchmark benchmarks
include("pkgbmark.jl")

end
