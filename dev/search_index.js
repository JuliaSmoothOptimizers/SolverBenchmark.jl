var documenterSearchIndex = {"docs": [

{
    "location": "#",
    "page": "Home",
    "title": "Home",
    "category": "page",
    "text": ""
},

{
    "location": "#Home-1",
    "page": "Home",
    "title": "SolverBenchmark.jl documentation",
    "category": "section",
    "text": "This package provides general tools for benchmarking solvers, focusing on a few guidelines:The output of a solver\'s run on a suite of problems is a DataFrame, where each row is a different problem.\nSince naming issues may arise (e.g., same problem with different number of variables), there must be an ID column;\nThe collection of two or more solver runs (DataFrames), is a Dict{Symbol,DataFrame}, where each key is a solver;Package objectives:Print to latex;\nPrint to pretty markdown table;\nProduce performance profiles.This package is developed focusing on Krylov.jl and Optimize.jl, but they should be general enough to be used in other places."
},

{
    "location": "api/#",
    "page": "API",
    "title": "API",
    "category": "page",
    "text": ""
},

{
    "location": "api/#API-1",
    "page": "API",
    "title": "API",
    "category": "section",
    "text": "Pages = [\"api.md\"]"
},

{
    "location": "api/#SolverBenchmark.format_table",
    "page": "API",
    "title": "SolverBenchmark.format_table",
    "category": "function",
    "text": "format_table(df, formatter, kwargs...)\n\nFormat the data frame into a table using formatter. Used by other table functions.\n\nInputs:\n\ndf::DataFrame: Dataframe of a solver. Each row is a problem.\nformatter::Function: A function that formats its input according to its type. See LTXformat or MDformat for examples.\n\nKeyword arguments:\n\ncols::Array{Symbol}: Which columns of the df. Defaults to using all columns;\nignore_missing_cols::Bool: If true, filters out the columns in cols that don\'t exist in the data frame. Useful when creating tables for solvers in a loop where one solver has a column the other doesn\'t. If false, throws BoundsError in that situation.\nfmt_override::Dict{Symbol,Function}: Overrides format for a specific column, such as\nfmt_override=Dict(:name => x->@sprintf(\"%-10s\", x))\nhdr_override::Dict{Symbol,String}: Overrides header names, such as hdr_override=Dict(:name => \"Name\").\n\nOutputs:\n\nheader::Array{String,1}: header vector.\ntable::Array{String,2}: formatted table.\n\n\n\n\n\n"
},

{
    "location": "api/#SolverBenchmark.latex_table",
    "page": "API",
    "title": "SolverBenchmark.latex_table",
    "category": "function",
    "text": "latex_table(io, df, kwargs...)\n\nCreate a latex longtable using LaTeXTabulars of a dataframe of results, formatting the output for a publication-ready table.\n\nInputs:\n\nio::IO: where to send the table, e.g.:\nopen(\"file.tex\", \"w\") do io\n  latex_table(io, df)\nend\ndf::DataFrame: Dataframe of a solver. Each row is a problem.\n\nKeyword arguments:\n\ncols::Array{Symbol}: Which columns of the df. Defaults to using all columns;\nignore_missing_cols::Bool: If true, filters out the columns in cols that don\'t exist in the data frame. Useful when creating tables for solvers in a loop where one solver has a column the other doesn\'t. If false, throws BoundsError in that situation.\nfmt_override::Dict{Symbol,Function}: Overrides format for a specific column, such as\nfmt_override=Dict(:name => x->@sprintf(\"\\textbf{%s}\", x) |> safe_latex_AbstractString)`\nhdr_override::Dict{Symbol,String}: Overrides header names, such as hdr_override=Dict(:name => \"Name\"), where LaTeX escaping should be used if necessary.\n\nWe recommend using the safe_latex_foo functions when overriding formats, unless you\'re sure you don\'t need them.\n\n\n\n\n\n"
},

{
    "location": "api/#SolverBenchmark.markdown_table",
    "page": "API",
    "title": "SolverBenchmark.markdown_table",
    "category": "function",
    "text": "markdown_table(io, df, kwargs...)\n\nCreate a markdown table using PrettyTables of a dataframe of results, formatting the output.\n\nInputs:\n\nio::IO: where to send the table, e.g.:\nopen(\"file.md\", \"w\") do io\n  markdown_table(io, df)\nend\ndf::DataFrame: Dataframe of a solver. Each row is a problem.\n\nKeyword arguments:\n\ncols::Array{Symbol}: Which columns of the df. Defaults to using all columns;\nignore_missing_cols::Bool: If true, filters out the columns in cols that don\'t exist in the data frame. Useful when creating tables for solvers in a loop where one solver has a column the other doesn\'t. If false, throws BoundsError in that situation.\nfmt_override::Dict{Symbol,Function}: Overrides format for a specific column, such as\nfmt_override=Dict(:name => x->@sprintf(\"%-10s\", x))\nhdr_override::Dict{Symbol,String}: Overrides header names, such as hdr_override=Dict(:name => \"Name\").\n\n\n\n\n\n"
},

{
    "location": "api/#Tables-1",
    "page": "API",
    "title": "Tables",
    "category": "section",
    "text": "format_table\nlatex_table\nmarkdown_table"
},

{
    "location": "api/#SolverBenchmark.LTXformat",
    "page": "API",
    "title": "SolverBenchmark.LTXformat",
    "category": "function",
    "text": "LTXformat(x)\n\nFormat x according to its type. For types Signed, AbstractFloat, AbstractString and Symbol, use a predefined formatting string passed to @sprintf and then the corresponding safe_latex_<type> function.\n\nFor type Missing, return \"NA\".\n\n\n\n\n\n"
},

{
    "location": "api/#SolverBenchmark.MDformat",
    "page": "API",
    "title": "SolverBenchmark.MDformat",
    "category": "function",
    "text": "MDformat(x)\n\nFormat x according to its type. For types Signed, AbstractFloat, AbstractString and Symbol, use a predefined formatting string passed to @sprintf.\n\nFor type Missing, return \"NA\".\n\n\n\n\n\n"
},

{
    "location": "api/#SolverBenchmark.safe_latex_AbstractFloat",
    "page": "API",
    "title": "SolverBenchmark.safe_latex_AbstractFloat",
    "category": "function",
    "text": "safe_latex_AbstractFloat(s)\n\nFor floats. Bypasses Inf and NaN. Enclose both the mantissa and the exponent in \\( and \\).\n\n\n\n\n\n"
},

{
    "location": "api/#SolverBenchmark.safe_latex_AbstractString",
    "page": "API",
    "title": "SolverBenchmark.safe_latex_AbstractString",
    "category": "function",
    "text": "safe_latex_AbstractString(s)\n\nFor strings. Replaces _ by \\_.\n\n\n\n\n\n"
},

{
    "location": "api/#SolverBenchmark.safe_latex_Signed",
    "page": "API",
    "title": "SolverBenchmark.safe_latex_Signed",
    "category": "function",
    "text": "safe_latex_Signed(s)\n\nFor signed integers. Encloses s in \\( and \\).\n\n\n\n\n\n"
},

{
    "location": "api/#SolverBenchmark.safe_latex_Symbol",
    "page": "API",
    "title": "SolverBenchmark.safe_latex_Symbol",
    "category": "function",
    "text": "safe_latex_Symbol(s)\n\nFor symbols. Same as strings.\n\n\n\n\n\n"
},

{
    "location": "api/#Formatting-1",
    "page": "API",
    "title": "Formatting",
    "category": "section",
    "text": "LTXformat\nMDformat\nsafe_latex_AbstractFloat\nsafe_latex_AbstractString\nsafe_latex_Signed\nsafe_latex_Symbol"
},

{
    "location": "reference/#",
    "page": "Reference",
    "title": "Reference",
    "category": "page",
    "text": ""
},

{
    "location": "reference/#Reference-1",
    "page": "Reference",
    "title": "Reference",
    "category": "section",
    "text": ""
},

]}
