using PrettyTables

export MDformat, markdown_table

for (typ, fmt) in formats
  @eval begin
    MDformat(x :: $typ) = @sprintf($fmt, x)
  end
end
MDformat(x :: Missing) = "NA"

@doc """
    MDformat(x)

Format `x` according to its type. For types `Signed`, `AbstractFloat`,
`AbstractString` and `Symbol`, use a predefined formatting string passed to
`@sprintf`.

For type `Missing`, return "NA".
"""
MDformat

"""
    markdown_table(io, df, kwargs...)

Create a markdown table using PrettyTables of a dataframe of results, formatting the
output.

Inputs:
- `io::IO`: where to send the table, e.g.:

      open("file.md", "w") do io
        markdown_table(io, df)
      end

- `df::DataFrame`: Dataframe of a solver. Each row is a problem.

Keyword arguments:
- `cols::Array{Symbol}`: Which columns of the `df`. Defaults to using all columns;
- `ignore_missing_cols::Bool`: If `true`, filters out the columns in `cols` that don't
  exist in the data frame. Useful when creating tables for solvers in a loop where one
  solver has a column the other doesn't. If `false`, throws `BoundsError` in that
  situation.
- `fmt_override::Dict{Symbol,Function}`: Overrides format for a specific column, such as

    fmt_override=Dict(:name => x->@sprintf("**%-10s**", x))

- `hdr_override::Dict{Symbol,String}`: Overrides header names, such as `hdr_override=Dict(:name => "Name")`.
"""
function markdown_table(io :: IO, df :: DataFrame; kwargs...)
  header, table = format_table(df, MDformat; kwargs...)
  pretty_table(io, table, header, markdown)
  nothing
end
