module SolverBenchmark

using Logging
using Printf

using ColorSchemes
using DataFrames
using JLD2
using LaTeXStrings
using PrettyTables

using NLPModels
using SolverCore

using Distributed

# reexport PrettyTable table formats for convenience
export unicode,
  ascii_dots,
  ascii_rounded,
  borderless,
  compact,
  tf_markdown,
  matrix,
  mysql,
  simple,
  unicode_rounded

# Tables
include("formats.jl")
include("latex_formats.jl")
include("highlighters.jl")
include("join.jl")

# Benchmark
include("run_solver.jl")
include("bmark_solvers.jl")
include("bmark_utils.jl")

# Profiles
include("profiles.jl")

# PkgBenchmark benchmarks
include("pkgbmark.jl")

end
