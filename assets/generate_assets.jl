using SolverBenchmark

# auxiliary packages
using DataFrames, Plots, Printf, Random
pyplot()

function generate_assets()
  # Fake data
  Random.seed!(0)
  n = 10
  names = [:alpha, :beta, :gamma]
  stats = Dict(name => DataFrame(:id => 1:n,
                                 :name => [@sprintf("prob%03d", i) for i = 1:n],
                                 :status => map(x -> x ? :success : :failure, rand(n) .< 0.75),
                                 :f => randn(n),
                                 :t => 1e-3 .+ rand(n) * 1000,
                                 :iter => rand(10:10:100, n)) for name in names)

  # Alpha table
  df = stats[:alpha]
  cols = [:status, :name, :f, :t, :iter]
  header = Dict(:status => "flag", :f => "\\(f(x)\\)", :t => "time")
  open("alpha.tex", "w") do io
    latex_table(io, df, cols=cols, hdr_override=header)
  end
  run(`latexmk -pdf alpha-standalone.tex`)
  run(`convert -density 150 alpha-standalone.pdf -background white -flatten alpha.png`)

  header = Dict(:status => "flag", :f => "f(x)", :t => "time")
  open("alpha.md", "w") do io
    markdown_table(io, df, cols=cols, hdr_override=header)
  end

  # Joined table
  df = join(stats, [:status, :f, :t], invariant_cols=[:name],
            hdr_override=Dict(:status => "flag"))

  open("joined.tex", "w") do io
    latex_table(io, df)
  end
  run(`latexmk -pdf joined-standalone.tex`)
  run(`convert -density 150 joined-standalone.pdf -background white -flatten joined.png`)

  open("joined.md", "w") do io
    markdown_table(io, df)
  end

  # Profile
  p = performance_profile(stats, df->df.t);
  Plots.png("profile1")
  p = profile_solvers(stats, [df->df.t, df->df.iter], ["Time", "Iterations"])
  Plots.png("profile2")
end

generate_assets()
