using LinearAlgebra

using BenchmarkTools

# make up bogus benchmark suite
SUITE = BenchmarkGroup()
SUITE["fact"] = BenchmarkGroup()
for _ = 1 : 10
    A = rand(10, 10)
    name = string(gensym())
    SUITE["fact"][name] = BenchmarkGroup()
    SUITE["fact"][name]["lu"] = @benchmarkable lu($A)
    SUITE["fact"][name]["qr"] = @benchmarkable qr($A)
end
