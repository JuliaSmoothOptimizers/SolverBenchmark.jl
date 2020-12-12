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
    @test all(chomp.(split(alpha_tex)) .== chomp.(split(String(take!(io)))))
  end

  @testset "alpha results in latex format with highlighting" begin
    header = Dict(:status => "flag", :f => "\\(f(x)\\)", :t => "time")
    hl = passfail_latex_highlighter(df)
    io = IOBuffer()
    pretty_latex_stats(io, df[!, cols], hdr_override=header, highlighters=hl)
    @test all(chomp.(split(alpha_hi_tex)) .== chomp.(split(String(take!(io)))))
  end

  @testset "alpha results in markdown format" begin
    header = Dict(:status => "flag", :f => "f(x)", :t => "time")
    fmts = Dict(:t => "%.2f")
    io = IOBuffer()
    pretty_stats(io, df[!, cols], col_formatters=fmts, hdr_override=header, tf=markdown)
    @test all(chomp.(split(alpha_md)) .== chomp.(split(String(take!(io)))))
  end

  @testset "alpha results in unicode format" begin
    header = Dict(:status => "flag", :f => "f(x)", :t => "time")
    fmts = Dict(:t => "%.2f")
    io = IOBuffer()
    pretty_stats(io, df[!, cols], col_formatters=fmts, hdr_override=header)
    @test all(chomp.(split(alpha_txt)) .== chomp.(split(String(take!(io)))))
  end

  @testset "Show all table output for joined solver" begin
    df = join(stats, [:status, :f, :t], invariant_cols=[:name],
              hdr_override=Dict(:status => "flag"))

    println(df)
  end

  @testset "joined results in latex format" begin
    io = IOBuffer()
    pretty_latex_stats(io, df)
    @test all(chomp.(split(joined_tex)) .== chomp.(split(String(take!(io)))))
  end

  @testset "joined results in markdown format" begin
    io = IOBuffer()
    pretty_stats(io, df, tf=markdown)
    @test all(chomp.(split(joined_md)) .== chomp.(split(String(take!(io)))))
  end

  @testset "missing values" begin
    df = DataFrame(A = [1.0, missing, 3.0], B = [missing, 1, 3],
                   C = [missing, "a", "b"], D = [missing, missing, :notmiss])
    io = IOBuffer()
    pretty_stats(io, df, tf=markdown)
    pretty_stats(stdout, df, tf=markdown)
    println(missing_md)
    @test all(chomp.(split(missing_md)) .== chomp.(split(String(take!(io)))))
    io = IOBuffer()
    pretty_latex_stats(io, df)
    @test all(chomp.(split(missing_ltx)) .== chomp.(split(String(take!(io)))))
  end
end

test_tables()
