# Test all table output
function test_tables()
  example_folder = joinpath(@__DIR__, "example")
  stats = get_stats_data() # from data.jl
  include("output_results.jl")

  df = stats[:alpha]
  cols = [:status, :name, :f, :t, :iter]

  @testset "alpha results in latex format" begin
    header = Dict(:status => "flag", :f => "\\(f(x)\\)", :t => "time")
    io = IOBuffer()
    pretty_latex_stats(io, df[!, cols], hdr_override=header)
    @test alpha_tex == String(take!(io))
  end

  @testset "alpha results in latex format with highlighting" begin
    header = Dict(:status => "flag", :f => "\\(f(x)\\)", :t => "time")
    hl = passfail_latex_highlighter(df)
    io = IOBuffer()
    pretty_latex_stats(io, df[!, cols], hdr_override=header, highlighters=hl)
    @test alpha_hi_tex == String(take!(io))
  end

  @testset "alpha results in markdown format" begin
    header = Dict(:status => "flag", :f => "f(x)", :t => "time")
    fmts = Dict(:t => "%.2f")
    io = IOBuffer()
    pretty_stats(io, df[!, cols], col_formatters=fmts, hdr_override=header, tf=markdown)
    @test alpha_md == String(take!(io))
  end

  @testset "alpha results in unicode format" begin
    header = Dict(:status => "flag", :f => "f(x)", :t => "time")
    fmts = Dict(:t => "%.2f")
    io = IOBuffer()
    pretty_stats(io, df[!, cols], col_formatters=fmts, hdr_override=header)
    @test alpha_txt == String(take!(io))
  end

  @testset "Show all table output for joined solver" begin
    df = join(stats, [:status, :f, :t], invariant_cols=[:name],
              hdr_override=Dict(:status => "flag"))

    println(df)
  end

  @testset "joined results in latex format" begin
    io = IOBuffer()
    pretty_latex_stats(io, df)
    @test joined_tex == String(take!(io))
  end

  @testset "joined results in markdown format" begin
    io = IOBuffer()
    pretty_stats(io, df, tf=markdown)
    @test joined_md == String(take!(io))
  end
end

test_tables()
