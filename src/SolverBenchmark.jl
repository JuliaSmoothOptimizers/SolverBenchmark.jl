module SolverBenchmark

# stdlib imports
using Printf

# dependencies imports
using ColorSchemes
using DataFrames
using PrettyTables

# reexport PrettyTable table formats for convenience
export unicode, ascii_dots, ascii_rounded, borderless, compact,
       markdown, matrix, mysql, simple, unicode_rounded

# Tables
include("formats.jl")
include("latex_formats.jl")
include("highlighters.jl")
include("join.jl")

# deprecated, remove in a future version
include("formatting.jl")
include("latex_tables.jl")
include("markdown_tables.jl")

# Profiles
include("profiles.jl")

# PkgBenchmark benchmarks
include("pkgbmark.jl")

end
