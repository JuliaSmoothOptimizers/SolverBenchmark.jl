# Test all table output
function test_tables()
  example_folder = joinpath(@__DIR__, "example")
  stats = get_stats_data() # from data.jl

  @info "Show all table output for single solver"
  df = stats[:alpha]
  cols = [:status, :name, :f, :t, :iter]

  @info "alpha results in DataFrame format"
  println(df[:, cols])

  @info "alpha results in latex format"
  old_lines = readlines("$example_folder/alpha.tex", keep=true)
  header = Dict(:status => "flag", :f => "\\(f(x)\\)", :t => "time")
  open("$example_folder/alpha.tex", "w") do io
    latex_table(io, df, cols=cols, hdr_override=header)
  end
  new_lines = readlines("$example_folder/alpha.tex", keep=true)
  println(join(new_lines))
  @test old_lines == new_lines

  @info "alpha results in markdown format"
  old_lines = readlines("$example_folder/alpha.md", keep=true)
  header = Dict(:status => "flag", :f => "f(x)", :t => "time")
  open("$example_folder/alpha.md", "w") do io
    markdown_table(io, df, cols=cols, hdr_override=header)
  end
  new_lines = readlines("$example_folder/alpha.md", keep=true)
  println(join(new_lines))
  @test old_lines == new_lines

  @info "Show all table output for joined solver"
  df = join(stats, [:status, :f, :t], invariant_cols=[:name],
            hdr_override=Dict(:status => "flag"))

  @info "joined results in DataFrame format"
  println(df)

  @info "joined results in latex format"
  old_lines = readlines("$example_folder/joined.tex", keep=true)
  open("$example_folder/joined.tex", "w") do io
    latex_table(io, df)
  end
  new_lines = readlines("$example_folder/joined.tex", keep=true)
  println(join(new_lines))
  @test old_lines == new_lines

  @info "joined results in markdown format"
  old_lines = readlines("$example_folder/joined.md", keep=true)
  open("$example_folder/joined.md", "w") do io
    markdown_table(io, df)
  end
  new_lines = readlines("$example_folder/joined.md", keep=true)
  println(join(new_lines))
  @test old_lines == new_lines
end

test_tables()
