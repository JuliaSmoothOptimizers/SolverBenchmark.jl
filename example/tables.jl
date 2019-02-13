# This file is essentially the same as test/tables.jl
# Watch for differences in future releases.

using DataFrames, LaTeXTabulars, Random, SolverBenchmark

function test_tables()
  Random.seed!(0)
  n = 10
  names = [:alpha, :beta, :gamma]
  stats = Dict(name => DataFrame(:id => 1:n,
                                 :status => map(x -> x ? :success : :failure, rand(n) .< 0.75),
                                 :f => randn(n),
                                 :t => 1e-3 .+ rand(n) * 1000,
                                 :iter => rand(10:10:100, n),
                                 :irrelevant => randn(n)) for name in names)

  @info("Show all table output for single solver")
  df = stats[:alpha]
  cols = [:status, :f, :t, :iter]

  @info("alpha result in latex format")
  header = Dict(:status => "flag", :f => "\\(f(x)\\)", :t => "time")
  open("alpha.tex", "w") do io
    latex_tabular_results(io, df, cols=cols, hdr_override=header)
  end
end

test_tables()
