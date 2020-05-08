export passfail_highlighter, passfail_latex_highlighter, gradient_highlighter

# helper function
function find_failure_ids(df::DataFrame)
  hasproperty(df, :status) ? df[(df.status .!= :first_order) .& (df.status .!= :unbounded), :].id : Int[]
end

"""
    hl = passfail_highlighter(df, c=crayon"bold red")

A PrettyTables highlighter that colors failures in bold red by default.

### Input Arguments

* `df::DataFrame` dataframe to which the highlighter will be applied.
    `df` must have the `id` column.

If `df` has the `:status` property, the highlighter will be applied to rows for which
`df.status` indicates a failure. A failure is any status different from `:first_order`
or `:unbounded`.
"""
function passfail_highlighter(df::DataFrame, c=crayon"bold red")
  # extract failure ids
  failure_id = find_failure_ids(df)
  Highlighter((data, i, j) -> i ∈ failure_id, c)
end

"""
    hl = passfail_latex_highlighter(df)

A PrettyTables LaTeX highlighter that colors failures in bold red by default.

See the documentation of `passfail_highlighter()` for more information.
"""
function passfail_latex_highlighter(df::DataFrame, c="cellcolor{red}")
  # NB: not obvious how to also use bold as \textbf{\(1.0e-03\)} will not appear in bold
  failure_id = find_failure_ids(df)
  LatexHighlighter((data, i, j) -> i ∈ failure_id, c)
end

"""
    hl = gradient_highlighter(df, col; cmap=:coolwarm)

A PrettyTables highlighter the applies a color gradient to the values in columns given by `cols`.

### Input Arguments

* `df::DataFrame` dataframe to which the highlighter will be applied;
* `col::Symbol` a symbol to indicate which column the highlighter will be applied to.

### Keyword Arguments

* `cmap::Symbol` color scheme to use, from ColorSchemes.
"""
function gradient_highlighter(df::DataFrame, col::Symbol; cmap::Symbol=:coolwarm)
  # inspired from https://ronisbr.github.io/PrettyTables.jl/stable/man/text_examples
  min_data = minimum(df[!, col])
  max_data = maximum(df[!, col])
  colidx = findfirst(x -> x == col, names(df))
  Highlighter((data,i,j) -> true,
              (h,data,i,j) -> begin
                                color = get(ColorSchemes.colorschemes[cmap], data[i, colidx], (min_data, max_data))
                                return Crayon(foreground = (round(Int,color.r*255),
                                                            round(Int,color.g*255),
                                                            round(Int,color.b*255)))
                              end)
end

