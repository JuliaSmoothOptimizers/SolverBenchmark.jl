# dependencies imports
using LaTeXTabulars

export latex_table, safe_latex_Signed, safe_latex_AbstractString,
       safe_latex_AbstractFloat, safe_latex_Symbol, LTXformat

"""`safe_latex_Signed(s)`

For signed integers. Encloses `s` in `\\(` and `\\)`.
"""
safe_latex_Signed(s :: AbstractString) = "\\(" * s * "\\)"

"""`safe_latex_AbstractString(s)`

For strings. Replaces `_` by `\\_`.
"""
safe_latex_AbstractString(s :: AbstractString) = replace(s, "_" => "\\_")

"""`safe_latex_AbstractFloat(s)`

For floats. Bypasses `Inf` and `NaN`. Enclose both the mantissa and the
exponent in `\\(` and `\\)`.
"""
function safe_latex_AbstractFloat(s :: AbstractString)
  strip(s) == "Inf" && return "\\(\\infty\\)"
  strip(s) == "-Inf" && return "\\(-\\infty\\)"
  strip(s) == "NaN" && return s
  mantissa, exponent = split(s, 'e')
  "\\(" * mantissa * "\\)e\\(" * exponent * "\\)"
end

"""`safe_latex_Symbol(s)`

For symbols. Same as strings.
"""
safe_latex_Symbol = safe_latex_AbstractString

for (typ, fmt) in formats
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

Create a latex longtable using LaTeXTabulars of a dataframe of results, formatting
the output for a publication-ready table.

Inputs:
- `io::IO`: where to send the table, e.g.:

      open("file.tex", "w") do io
        latex_table(io, df)
      end

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
  header, table = format_table(df, LTXformat; kwargs...)
  latex_tabular(io, LongTable("l" * "r"^(length(header)-1), header),
                [table, Rule()])
  nothing
end
