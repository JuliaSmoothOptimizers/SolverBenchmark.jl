module SolverBenchmark

# stdlib impots
using Printf

# dependencies imports
using DataFrames

const formats = Dict{DataType, String}(Signed => "%5d",
                                       AbstractFloat => "%8.1e",
                                       AbstractString => "%s",
                                       Symbol => "%s")

include("latex_tables.jl")
include("markdown_tables.jl")

end
