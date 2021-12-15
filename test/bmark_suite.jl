using LinearAlgebra

using BenchmarkTools

# make up bogus benchmark suite
SUITE = BenchmarkGroup()
SUITE["lu"] = BenchmarkGroup()
SUITE["qr"] = BenchmarkGroup()
for _ = 1:10
  A = rand(10, 10)
  name = string(gensym())
  SUITE["lu"][name] = @benchmarkable lu($A)
  SUITE["qr"][name] = @benchmarkable qr($A)
end
