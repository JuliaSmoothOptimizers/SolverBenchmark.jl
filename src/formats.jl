export pretty_stats

const default_formatters = Dict(AbstractFloat => "%9.2e",
                                Signed => "%6d",
                                AbstractString => "%15s",
                                Symbol => "%15s",
                               )

"""
    pretty_stats(df; kwargs...)

Pretty-print a DataFrame using PrettyTables.

### Arguments

* `io::IO`: an IO stream to which the table will be output (default: `stdout`);
* `df::DataFrame`: the DataFrame to be displayed. If only certain columns of `df` should be displayed,
      they should be extracted explicitly, e.g., by passing `df[!, [:col1, :col2, :col3]]`.

### Keyword Arguments

* `col_formatters::Dict{Symbol, String}`: a Dict of format strings to apply to selected columns of `df`.
      The keys of `col_formatters` should be symbols, so that specific formatting can be applied to specific columns.
      By default, `default_formatters` is used, based on the column type.
      If PrettyTables formatters are passed using the `formatters` keyword argument, they are applied
      before those in `col_formatters`.

* `hdr_override::Dict{Symbol, String}`: a Dict of those headers that should be displayed differently than
      simply according to the column name (default: empty). Example: `Dict(:col1 => "column 1")`.

All other keyword arguments are passed directly to `pretty_table`.
In particular,

* use `tf=tf_markdown` to display a Markdown table;
* do not use this function for LaTeX output; use `pretty_latex_stats` instead;
* any PrettyTables highlighters can be given, but see the predefined `passfail_highlighter` and `gradient_highlighter`.
"""
function pretty_stats(io::IO, df::DataFrame;
                      col_formatters=default_formatters,
                      hdr_override :: Dict{Symbol,String} = Dict{Symbol,String}(),
                      kwargs...)
  kwargs = Dict(kwargs)
  pt_formatters = []

  # if PrettyTable formatters are given, apply those first
  if :formatters ∈ keys(kwargs)
    kw_fmts = pop!(kwargs, :formatters)
    if typeof(kw_fmts) <: Tuple
      for fmt ∈ kw_fmts
        push!(pt_formatters, fmt)
      end
    else
      push!(pt_formatters, kw_fmts)
    end
  end

  # merge default and user-specified column formatters
  df_names = propertynames(df)
  for col = 1 : length(df_names)
    name = df_names[col]
    if name ∈ keys(col_formatters)
      push!(pt_formatters, ft_printf(col_formatters[name], col))
    else
      typ = Missings.nonmissingtype(eltype(df[!, name]))
      styp = supertype(typ)
      push!(pt_formatters, ft_printf(default_formatters[typ == Symbol ? typ : styp], col))
    end
  end

  # set header
  header = String[]
  for name ∈ df_names
    push!(header, name ∈ keys(hdr_override) ? hdr_override[name] : String(name))
  end

  # set nosubheader=true to avoid printing the column data types
  :nosubheader ∈ keys(kwargs) && pop!(kwargs, :nosubheader)

  # pretty_table expects a tuple of formatters
  pretty_table(io, df, header=header,
               formatters=tuple(pt_formatters...), nosubheader=true; kwargs...)
end

pretty_stats(df::DataFrame; kwargs...) = pretty_stats(stdout, df; kwargs...)

