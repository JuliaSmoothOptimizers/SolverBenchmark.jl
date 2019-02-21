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
    "location": "api/#Base.join",
    "page": "API",
    "title": "Base.join",
    "category": "function",
    "text": "df = join(stats, cols; kwargs...)\n\nJoin a dictionary of DataFrames given by stats. Column :id is required in all DataFrames. The resulting DataFrame will have column id and all columns cols for each solver.\n\nInputs:\n\nstats::Dict{Symbol,DataFrame}: Dictionary of DataFrames per solver. Each key is a different solver;\ncols::Array{Symbol}: Which columns of the DataFrames.\n\nKeyword arguments:\n\ninvariant_cols::Array{Symbol,1}: Invariant columns to be added, i.e., columns that don\'t change depending on the solver (such as name of problem, number of variables, etc.);\nhdr_override::Dict{Symbol,String}: Override header names.\n\nOutput:\n\ndf::DataFrame: Resulting dataframe.\n\n\n\n\n\n"
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
    "text": "format_table\njoin\nlatex_table\nmarkdown_table"
},

{
    "location": "api/#SolverBenchmark.bmark_results_to_dataframes",
    "page": "API",
    "title": "SolverBenchmark.bmark_results_to_dataframes",
    "category": "function",
    "text": "stats = bmark_results_to_dataframes(results)\n\nConvert PkgBenchmark results to a dictionary of DataFrames.\n\nInputs:\n\nresults::BenchmarkResults: the result of PkgBenchmark.benchmarkpkg()\n\nOutput:\n\nstats::Dict{Symbol,DataFrame}: a dictionary of DataFrames containing the   benchmark results per solver.\n\n\n\n\n\n"
},

{
    "location": "api/#SolverBenchmark.judgement_results_to_dataframes",
    "page": "API",
    "title": "SolverBenchmark.judgement_results_to_dataframes",
    "category": "function",
    "text": "stats = judgement_results_to_dataframes(judgement)\n\nConvert BenchmarkJudgement results to a dictionary of DataFrames.\n\nInputs:\n\njudgement::BenchmarkJudgement: the result of, e.g.,\ncommit = benchmarkpkg(mypkg)  # benchmark a commit or pull request\nmaster = benchmarkpkg(mypkg, \"master\")  # baseline benchmark\njudgement = judge(commit, master)\n\nOutput:\n\nstats::Dict{Symbol,DataFrame}: a dictionary of DataFrames containing the   target and baseline benchmark results.\n\n\n\n\n\n"
},

{
    "location": "api/#SolverBenchmark.to_gist",
    "page": "API",
    "title": "SolverBenchmark.to_gist",
    "category": "function",
    "text": "posted_gist = to_gist(results, p)\n\nCreate and post a gist with the benchmark results and performance profiles.\n\nInputs:\n\nresults::BenchmarkResults: the result of PkgBenchmark.benchmarkpkg()\np:: the result of profile_solvers().\n\nOutput:\n\nthe return value of GitHub.jl\'s create_gist().\n\n\n\n\n\nposted_gist = to_gist(results)\n\nCreate and post a gist with the benchmark results and performance profiles.\n\nInputs:\n\nresults::BenchmarkResults: the result of PkgBenchmark.benchmarkpkg()\n\nOutput:\n\nthe return value of GitHub.jl\'s create_gist().\n\n\n\n\n\n"
},

{
    "location": "api/#PkgBenchmark-1",
    "page": "API",
    "title": "PkgBenchmark",
    "category": "section",
    "text": "bmark_results_to_dataframes\njudgement_results_to_dataframes\nto_gist"
},

{
    "location": "api/#BenchmarkProfiles.performance_profile",
    "page": "API",
    "title": "BenchmarkProfiles.performance_profile",
    "category": "function",
    "text": "performance_profile(stats, cost)\n\nProduce a performance profile comparing solvers in stats using the cost function.\n\nInputs:\n\nstats::Dict{Symbol,DataFrame}: pairs of :solver => df;\ncost::Function: cost function applyed to each df. Should return a vector with the cost of solving the problem at each row;\n0 cost is not allowed;\nIf the solver did not solve the problem, return Inf or a negative number.\n\nExamples of cost functions:\n\ncost(df) = df.elapsed_time: Simple elapsed_time cost. Assumes the solver solved the problem.\ncost(df) = (df.status .!= :first_order) * Inf + df.elapsed_time: Takes into consideration the status of the solver.\n\n\n\n\n\n"
},

{
    "location": "api/#SolverBenchmark.profile_solvers",
    "page": "API",
    "title": "SolverBenchmark.profile_solvers",
    "category": "function",
    "text": "p = profile_solvers(stats, costs, costnames)\n\nProduce performance profiles comparing solvers based on the data in stats.\n\nInputs:\n\nstats::Dict{Symbol,DataFrame}: a dictionary of DataFrames containing the   benchmark results per solver (e.g., produced by bmark_results_to_dataframes())\ncosts::Vector{Function}: a vector of functions specifying the measures to use in the profiles\ncostnames::Vector{String}: names to be used as titles of the profiles.\n\nOutput: A Plots.jl plot representing a set of performance profiles comparing the solvers. The set contains performance profiles comparing all the solvers together on the measures given in costs. If there are more than two solvers, additional profiles are produced comparing the solvers two by two on each cost measure.\n\n\n\n\n\np = profile_solvers(results)\n\nProduce performance profiles based on PkgBenchmark.benchmarkpkg results.\n\nInputs:\n\nresults::BenchmarkResults: the result of PkgBenchmark.benchmarkpkg().\n\n\n\n\n\n"
},

{
    "location": "api/#SolverBenchmark.profile_package",
    "page": "API",
    "title": "SolverBenchmark.profile_package",
    "category": "function",
    "text": "p = profile_package(judgement)\n\nProduce performance profiles based on PkgBenchmark.BenchmarkJudgement results.\n\nInputs:\n\njudgement::BenchmarkJudgement: the result of, e.g.,\ncommit = benchmarkpkg(mypkg)  # benchmark a commit or pull request\nmaster = benchmarkpkg(mypkg, \"master\")  # baseline benchmark\njudgement = judge(commit, master)\n\n\n\n\n\n"
},

{
    "location": "api/#Profiles-1",
    "page": "API",
    "title": "Profiles",
    "category": "section",
    "text": "performance_profile\nprofile_solvers\nprofile_package"
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
