# dependencies imports
using LaTeXTabulars

for (typ, fmt) in default_formatters
  safe = Symbol("safe_latex_$typ")
  @eval begin
    LTXformat(x :: $typ) = @sprintf($fmt, x) |> $safe
  end
end
LTXformat(x :: Missing) = "NA"

@doc """
    LTXformat(x)

Format `x` according to its type. For types `Signed`, `AbstractFloat`,
`AbstractString` and `Symbol`, use a predefined formatting string passed to
`@sprintf` and then the corresponding `safe_latex_<type>` function.

For type `Missing`, return "NA".
"""
LTXformat

"""
    latex_table(io, df, kwargs...)

Create a latex longtable of a DataFrame using LaTeXTabulars, and format the output for a publication-ready table.

Inputs:
- `io::IO`: where to send the table, e.g.:

      open("file.tex", "w") do io
        latex_table(io, df)
      end

  If left out, `io` defaults to `stdout`.

- `df::DataFrame`: Dataframe of a solver. Each row is a problem.

Keyword arguments:
- `cols::Array{Symbol}`: Which columns of the `df`. Defaults to using all columns;
- `ignore_missing_cols::Bool`: If `true`, filters out the columns in `cols` that don't
  exist in the data frame. Useful when creating tables for solvers in a loop where one
  solver has a column the other doesn't. If `false`, throws `BoundsError` in that
  situation.
- `fmt_override::Dict{Symbol,Function}`: Overrides format for a specific column, such as

      fmt_override=Dict(:name => x->@sprintf("\\textbf{%s}", x) |> safe_latex_AbstractString)`

- `hdr_override::Dict{Symbol,String}`: Overrides header names, such as
  `hdr_override=Dict(:name => "Name")`, where LaTeX escaping should be used if necessary.

We recommend using the `safe_latex_foo` functions when overriding formats, unless
you're sure you don't need them.
"""
function latex_table(io :: IO, df :: DataFrame; kwargs...)
  header, table, _ = format_table(df, LTXformat; kwargs...)  # ignore highlighter
  latex_tabular(io, LongTable("l" * "r"^(length(header)-1), header),
                [table, Rule()])
  nothing
end

latex_table(df :: DataFrame; kwargs...) = latex_table(stdout, df; kwargs...)

Base.@deprecate latex_table pretty_latex_stats true
