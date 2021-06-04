export pretty_latex_stats

"""
    safe_latex_Signed_col(col::Integer)

Generate a PrettyTables LaTeX formatter for signed integers.
"""
function safe_latex_Signed_col(col::Integer)
  return (s, i, j) -> begin
                        j !== col && return s
                        return ismissing(s) ? " "^10 : safe_latex_Signed(s)
                      end
end

"""
    safe_latex_Signed(s::AbstractString)

Format the string representation of signed integers for output in a LaTeX table.
Encloses `s` in `\\(` and `\\)`.
"""
safe_latex_Signed(s::AbstractString) = "\\(" * s * "\\)"

"""
    safe_latex_AbstractString_col(col:::Integer)

Generate a PrettyTables LaTeX formatter for strings.
Replaces `_` with `\\_`.
"""
function safe_latex_AbstractString_col(col::Integer)
  return (s, i, j) -> begin
                        j !== col && return s
                        ismissing(s) ? " " : safe_latex_AbstractString(s)
                      end
end

"""
    safe_latex_AbstractString(s::AbstractString)

Format a string for output in a LaTeX table.
Escapes underscores.
"""
safe_latex_AbstractString(s::AbstractString) = replace(s, "_" => "\\_")

"""
    safe_latex_Symbol_col(col::Integer)

Generate a PrettyTables LaTeX formatter for symbols.
"""
function safe_latex_Symbol_col(col::Integer)
  return (s, i, j) -> begin
                        j !== col && return s
                        safe_latex_Symbol(s)
                      end
end

"""
    safe_latex_Symbol(s)

Format a symbol for output in a LaTeX table.
Calls `safe_latex_AbstractString(string(s))`.
"""
safe_latex_Symbol(s) = safe_latex_AbstractString(string(s))

"""
    safe_latex_AbstractFloat_col(col::Integer)

Generate a PrettyTables LaTeX formatter for real numbers.
"""
function safe_latex_AbstractFloat_col(col::Integer)
  # by this point, the table value should already have been converted to a string
  return (s, i, j) -> begin
                        j != col && return s
                        return ismissing(s) ? " "^17 : safe_latex_AbstractFloat(s)
                      end
end

"""
    safe_latex_AbstractFloat(s::AbstractString)

Format the string representation of floats for output in a LaTeX table.
Replaces infinite values with the `\\infty` LaTeX sequence.
If the float is represented in exponential notation, the mantissa and exponent
are wrapped in math delimiters.
Otherwise, the entire float is wrapped in math delimiters.
"""
function safe_latex_AbstractFloat(s::AbstractString)
  strip(s) == "Inf" && return "\\(\\infty\\)"
  strip(s) == "-Inf" && return "\\(-\\infty\\)"
  strip(s) == "NaN" && return s
  if occursin('e', s)
    mantissa, exponent = split(s, 'e')
    return "\\(" * mantissa * "\\)e\\(" * exponent * "\\)"
  else
    return "\\(" * s * "\\)"
  end
end

safe_latex_formatters = Dict(AbstractFloat => safe_latex_AbstractFloat_col,
                             Signed => safe_latex_Signed_col,
                             AbstractString => safe_latex_AbstractString_col,
                             Symbol => safe_latex_Symbol_col)

"""
    pretty_latex_stats(df; kwargs...)

Pretty-print a DataFrame as a LaTeX longtable using PrettyTables.

See the `pretty_stats` documentation. Specific settings in this method are:

* the backend is set to `:latex`;
* the table type is set to `:longtable`;
* highlighters, if any, should be LaTeX highlighters.

See the PrettyTables documentation for more information.
"""
function pretty_latex_stats(io::IO, df::DataFrame;
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
    typ = Missings.nonmissingtype(eltype(df[!, name]))
    styp = supertype(typ)
    if name ∈ keys(col_formatters)
      push!(pt_formatters, ft_printf(col_formatters[name], col))
    else
      # be careful because supertype(Symbol) = Any
      push!(pt_formatters, ft_printf(default_formatters[typ == Symbol ? typ : styp], col))
    end
    # add LaTeX-specific formatters to make our table pretty
    push!(pt_formatters, safe_latex_formatters[typ == Symbol ? typ : styp](col))
  end

  # set header
  header = String[]
  for name ∈ df_names
    push!(header, name ∈ keys(hdr_override) ? hdr_override[name] : (String(name) |> safe_latex_AbstractString))
  end

  # force a few options
  for s ∈ (:nosubheader, :backend, :table_type, :tf)
    s ∈ keys(kwargs) && pop!(kwargs, s)
  end

  # by default, PrettyTables wants to boldface headers
  # that won't work if we put any math headers
  tf = LatexTableFormat(
    top_line       = "\\hline",
    header_line    = "\\hline",
    mid_line       = "\\hline",
    bottom_line    = "\\hline",
    left_vline     = "|",
    mid_vline      = "|",
    right_vline    = "|",
    header_envs    = [],
    subheader_envs = ["texttt"],
  )

  # pretty_table expects a tuple of formatters
  pretty_table(io, df, header,
               backend=:latex, table_type=:longtable, tf=tf, nosubheader=true,
               longtable_footer="{\\bfseries Continued on next page}",
               formatters=tuple(pt_formatters...); kwargs...)
end

pretty_latex_stats(df::DataFrame; kwargs...) = pretty_latex_stats(stdout, df; kwargs...)

