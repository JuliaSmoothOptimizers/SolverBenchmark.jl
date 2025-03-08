# Test all table output
macro setup_table_data()
  return quote
    stats = get_stats_data() # from data.jl
    include("output_results.jl")
    df = stats[:alpha]
    cols = [:status, :name, :f, :t, :iter]
  end
end

function test_tables()
  @testset "alpha results in latex format" begin
    @setup_table_data
    header = Dict(:status => "flag", :f => "\\(f(x)\\)", :t => "time")
    io = IOBuffer()
    pretty_latex_stats(io, df[!, cols], hdr_override = header)
    @test all(chomp.(split(alpha_tex)) .== chomp.(split(String(take!(io)))))
  end

  @testset "alpha results in latex format with highlighting" begin
    @setup_table_data
    header = Dict(:status => "flag", :f => "\\(f(x)\\)", :t => "time")
    hl = passfail_latex_highlighter(df)
    io = IOBuffer()
    pretty_latex_stats(io, df[!, cols], hdr_override = header, highlighters = hl)
    @test all(chomp.(split(alpha_hi_tex)) .== chomp.(split(String(take!(io)))))
  end

  @testset "alpha results in markdown format" begin
    @setup_table_data
    header = Dict(:status => "flag", :f => "f(x)", :t => "time")
    fmts = Dict(:t => "%.2f")
    io = IOBuffer()
    pretty_stats(io, df[!, cols], col_formatters = fmts, hdr_override = header, tf = tf_markdown)
    @test all(chomp.(split(alpha_md)) .== chomp.(split(String(take!(io)))))
  end

  @testset "alpha results in unicode format" begin
    @setup_table_data
    header = Dict(:status => "flag", :f => "f(x)", :t => "time")
    fmts = Dict(:t => "%.2f")
    io = IOBuffer()
    pretty_stats(io, df[!, cols], col_formatters = fmts, hdr_override = header)
    @test all(chomp.(split(alpha_txt)) .== chomp.(split(String(take!(io)))))
  end

  @testset "Show all table output for joined solver" begin
    @setup_table_data
    df = join(
      stats,
      [:status, :f, :t],
      invariant_cols = [:name],
      hdr_override = Dict(:status => "flag"),
    )

    println(df)
  end

  @testset "joined results in latex format" begin
    @setup_table_data
    io = IOBuffer()
    pretty_latex_stats(io, df)
    @test all(chomp.(split(joined_tex)) .== chomp.(split(String(take!(io)))))
  end

  @testset "joined results in markdown format" begin
    @setup_table_data
    io = IOBuffer()
    pretty_stats(io, df, tf = tf_markdown)
    @test all(chomp.(split(joined_md)) .== chomp.(split(String(take!(io)))))
  end

  @testset "missing values" begin
    @setup_table_data
    df = DataFrame(
      A = [1.0, missing, 3.0],
      B = [missing, 1, 3],
      C = [missing, "a", "b"],
      D = [missing, missing, :notmiss],
    )
    io = IOBuffer()
    pretty_stats(io, df, tf = tf_markdown)
    pretty_stats(stdout, df, tf = tf_markdown)
    println(missing_md)
    @test all(chomp.(split(missing_md)) .== chomp.(split(String(take!(io)))))
    io = IOBuffer()
    pretty_latex_stats(io, df)
    @test all(chomp.(split(missing_ltx)) .== chomp.(split(String(take!(io)))))
  end
end

test_tables()
