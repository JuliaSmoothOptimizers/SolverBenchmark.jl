import Base.join

export join

"""
    df = join(stats, cols; kwargs...)

Join a dictionary of DataFrames given by `stats`. Column `:id` is required in all
DataFrames. The resulting DataFrame will have column `id` and all columns `cols` for
each solver.

Inputs:
- `stats::Dict{Symbol,DataFrame}`: Dictionary of DataFrames per solver. Each key is a different solver;
- `cols::Array{Symbol}`: Which columns of the DataFrames.

Keyword arguments:
- `invariant_cols::Array{Symbol,1}`: Invariant columns to be added, i.e., columns that don't change depending on the solver (such as name of problem, number of variables, etc.);
- `hdr_override::Dict{Symbol,String}`: Override header names.

Output:
- `df::DataFrame`: Resulting dataframe.
"""
function join(
  stats::Dict{Symbol, DataFrame},
  cols::Array{Symbol, 1};
  invariant_cols::Array{Symbol, 1} = Symbol[],
  hdr_override::Dict{Symbol, String} = Dict{Symbol, String}(),
)
  length(cols) == 0 && error("cols can't be empty")
  if !all(:id in propertynames(df) for (s, df) in stats)
    error("Missing column :id in some DataFrame")
  elseif !all(setdiff(cols, propertynames(df)) == [] for (s, df) in stats)
    error("Not all DataFrames have all columns given by `cols`")
  end

  if :id in cols
    deleteat!(cols, findall(cols .== :id))
  end
  if :id in invariant_cols
    deleteat!(cols, findall(cols .== :id))
  end
  invariant_cols = [:id; invariant_cols]
  cols = setdiff(cols, invariant_cols)
  if length(cols) == 0
    error("All columns are invariant")
  end
  cols = [:id; cols]

  s = first(stats)[1]
  df = stats[s][:, invariant_cols]

  rename_f(c, s) = begin
    symbol_c = Symbol(c)
    symbol_c in invariant_cols && return symbol_c
    sc = haskey(hdr_override, symbol_c) ? hdr_override[symbol_c] : c
    Symbol(sc * "_$s")
  end

  for (s, dfs) in stats
    df = innerjoin(df, rename(c -> rename_f(c, s), dfs[!, cols]), on = :id, makeunique = true)
  end

  return df
end
