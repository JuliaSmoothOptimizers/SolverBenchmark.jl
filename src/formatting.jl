export format_table

const formats = Dict{DataType, String}(Signed => "%5d",
                                       AbstractFloat => "%8.1e",
                                       AbstractString => "%s",
                                       Symbol => "%s")

"""
    format_table(df, formatter, kwargs...)

Format the data frame into a table using `formatter`. Used by other table functions.

Inputs:
- `df::DataFrame`: Dataframe of a solver. Each row is a problem.
- `formatter::Function`: A function that formats its input according to its type. See `LTXformat` or `MDformat` for examples.

Keyword arguments:
- `cols::Array{Symbol}`: Which columns of the `df`. Defaults to using all columns;
- `ignore_missing_cols::Bool`: If `true`, filters out the columns in `cols` that don't
  exist in the data frame. Useful when creating tables for solvers in a loop where one
  solver has a column the other doesn't. If `false`, throws `BoundsError` in that
  situation.
- `fmt_override::Dict{Symbol,Function}`: Overrides format for a specific column, such as

    fmt_override=Dict(:name => x->@sprintf("**%-10s**", x))

- `hdr_override::Dict{Symbol,String}`: Overrides header names, such as `hdr_override=Dict(:name => "Name")`.

Outputs:
- `header::Array{String,1}`: header vector.
- `table::Array{String,2}`: formatted table.
"""
function format_table(df :: DataFrame, formatter::Function;
                      cols :: Array{Symbol,1} = names(df),
                      ignore_missing_cols :: Bool = false,
                      fmt_override :: Dict{Symbol,F} = Dict{Symbol,Function}(),
                      hdr_override :: Dict{Symbol,String} = Dict{Symbol,String}(),
                     ) where F <: Function
  if ignore_missing_cols
    cols = filter(c->hasproperty(df, c), cols)
  elseif !all(hasproperty(df, c) for c in cols)
    missing_cols = setdiff(cols, names(df))
    @error("There are no columns `" * join(missing_cols, ", ") * "` in dataframe")
    throw(BoundsError)
  end
  local hl
  if hasproperty(df, :status)
    # extract failure ids
    failure_id = df[(df.status .!= :first_order) .& (df.status .!= :unbounded), :].id
    hl = Highlighter(f = (data, i, j) -> i ∈ failure_id, crayon = crayon"bold red")
  else
    hl = Highlighter(f = (data, i, j) -> false, crayon = crayon"black")
  end

  string_cols = [map(haskey(fmt_override, col) ? fmt_override[col] : formatter, df[!, col]) for col in cols]
  table = hcat(string_cols...)

  header = [haskey(hdr_override, c) ? hdr_override[c] : formatter(c) for c in cols]

  return header, table, hl
end
