for (typ, fmt) in default_formatters
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

Create a markdown table from a DataFrame using PrettyTables and format the output.

Inputs:
- `io::IO`: where to send the table, e.g.:

      open("file.md", "w") do io
        markdown_table(io, df)
      end

  If left out, `io` defaults to `stdout`.

- `df::DataFrame`: Dataframe of a solver. Each row is a problem.

Keyword arguments:
- `hl`: a highlighter or tuple of highlighters to color individual cells (when output to screen).
        By default, we use a simple `passfail_highlighter()`.

- all other keyword arguments are passed directly to `format_table()`.
"""
function markdown_table(io :: IO, df :: DataFrame; hl=passfail_highlighter(df), kwargs...)
  header, table = format_table(df, MDformat; kwargs...)
  pretty_table(io, table, header, tf=markdown, highlighters=hl)
end

markdown_table(df :: DataFrame; kwargs...) = markdown_table(stdout, df; kwargs...)

Base.@deprecate markdown_table pretty_stats false
