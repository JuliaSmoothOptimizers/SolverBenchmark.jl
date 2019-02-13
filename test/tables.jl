# Test all table output
function test_tables()
  example_folder = joinpath(@__DIR__, "example")
  println(example_folder)
  Random.seed!(0)
  n = 10
  names = [:alpha, :beta, :gamma]
  stats = Dict(name => DataFrame(:id => 1:n,
                                 :status => map(x -> x ? :success : :failure, rand(n) .< 0.75),
                                 :f => randn(n),
                                 :t => 1e-3 .+ rand(n) * 1000,
                                 :iter => rand(10:10:100, n),
                                 :irrelevant => randn(n)) for name in names)

  @info "Show all table output for single solver"
  df = stats[:alpha]
  cols = [:status, :f, :t, :iter]

  @info "alpha results in DataFrame format"
  println(df[cols])

  @info "alpha results in latex format"
  old_lines = readlines("$example_folder/alpha.tex", keep=true)
  header = Dict(:status => "flag", :f => "\\(f(x)\\)", :t => "time")
  open("$example_folder/alpha.tex", "w") do io
    latex_table(io, df, cols=cols, hdr_override=header)
  end
  new_lines = readlines("$example_folder/alpha.tex", keep=true)
  println(join(new_lines))
  @test old_lines == new_lines
end

test_tables()
