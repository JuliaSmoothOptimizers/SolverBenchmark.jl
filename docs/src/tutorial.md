# Tutorial

In this tutorial we illustrate the main uses of `SolverBenchmark`.

First, let's create fake data. It is imperative that the data for each solver be stored
in `DataFrame`s, and the collection of different solver must be stored in a dictionary of
`Symbol` to `DataFrame`.

In our examples we'll use the following data.

```@example ex1
using DataFrames, Printf, Random

Random.seed!(0)

n = 10
names = [:alpha, :beta, :gamma]
stats = Dict(name => DataFrame(:id => 1:n,
         :name => [@sprintf("prob%03d", i) for i = 1:n],
         :status => map(x -> x < 0.75 ? :success : :failure, rand(n)),
         :f => randn(n),
         :t => 1e-3 .+ rand(n) * 1000,
         :iter => rand(10:10:100, n),
         :irrelevant => randn(n)) for name in names)
```

The data consists of a (fake) run of three solvers `alpha`, `beta` and `gamma`.
Each solver has a column `id`, which is necessary for joining the solvers (names
can be repeated), and columns `name`, `status`, `f`, `t` and `iter` corresponding to
problem results. There is also a column `irrelevant` with extra information that will
not be used to produce our benchmarks.

Here are the statistics of solver `alpha`:

```@example ex1
stats[:alpha]
```

## Tables

The first thing we may want to do is produce a table for each solver. Notice that the
solver result is already a DataFrame, so there are a few options available in other
packages, as well as simply printing the DataFrame.
Our concern here is two-fold: producing publication-ready LaTeX tables, and web-ready
markdown tables.

The simplest use is `foo_table(io, dataframe)`. Here is printout to the `stdout`:

```@example ex1
using SolverBenchmark

markdown_table(stdout, stats[:alpha])
```

```@example ex1
latex_table(stdout, stats[:alpha])
```

Alternatively, you can print to a file.

```@example ex1
open("alpha.tex", "w") do io
  println(io, "\\documentclass[varwidth=20cm,crop=true]{standalone}")
  println(io, "\\usepackage{longtable}")
  println(io, "\\begin{document}")
  latex_table(io, stats[:alpha])
  println(io, "\\end{document}")
end
```

```@example ex1
run(`latexmk -quiet -pdf alpha.tex`)
run(`pdf2svg alpha.pdf alpha.svg`)
```

![](alpha.svg)

The main options for both `table` commands is `cols`, which defines which columns to
use.

```@example ex1
markdown_table(stdout, stats[:alpha], cols=[:name, :f, :t])
```

Notice that passing a column that does not exist will throw an error, but you can pass
`ignore_missing_cols=true` to simply ignore that column.

The `fmt_override` option overrides the formatting of a specific column. The  argument
should be a dictionary of `Symbol` to functions, where the functions will be applied to
each element of the column.

The `hdr_override` simply changes the name of the column.

```@example ex1
fmt_override = Dict(:f => x->@sprintf("%+10.3e", x),
                    :t => x->@sprintf("%08.2f", x))
hdr_override = Dict(:name => "Name", :f => "f(x)", :t => "Time")
markdown_table(stdout, stats[:alpha], cols=[:name, :f, :t], fmt_override=fmt_override, hdr_override=hdr_override)
```

This allows for elaborate things, such as

```@example ex1
function time_fmt(x)
  xi = floor(Int, x)
  minutes = div(xi, 60)
  seconds = xi % 60
  micros  = round(Int, 1e6 * (x - xi))
  @sprintf("%2dm %02ds %06dμs", minutes, seconds, micros)
end
fmt_override = Dict(:f => x->@sprintf("%+10.3e", x), :t => time_fmt)
hdr_override = Dict(:name => "Name", :f => "f(x)", :t => "Time")
markdown_table(stdout, stats[:alpha], cols=[:name, :f, :t], fmt_override=fmt_override, hdr_override=hdr_override)
```

Notice that for `latex_table`, the output must be understood by the LaTeX compiler.
To that end, we have a few functions that convert a specific element into a LaTeX-safe
string: [`safe_latex_AbstractFloat`](@ref), [`safe_latex_AbstractString`](@ref),
[`safe_latex_Symbol`](@ref) and [`safe_latex_Signed`](@ref).

```@example ex1
function time_fmt(x)
  xi = floor(Int, x)
  minutes = div(xi, 60)
  seconds = xi % 60
  micros  = round(Int, 1e6 * (x - xi))
  @sprintf("\\(%2d\\)m \\(%02d\\)s \\(%06d\\mu s\\)", minutes, seconds, micros)
end
fmt_override = Dict(:f => x->@sprintf("%+10.3e", x) |> safe_latex_AbstractFloat,
                    :t => time_fmt)
hdr_override = Dict(:name => "Name", :f => "\\(f(x)\\)", :t => "Time")
open("alpha2.tex", "w") do io
  println(io, "\\documentclass[varwidth=20cm,crop=true]{standalone}")
  println(io, "\\usepackage{longtable}")
  println(io, "\\begin{document}")
  latex_table(io, stats[:alpha], cols=[:name, :f, :t], fmt_override=fmt_override, hdr_override=hdr_override)
  println(io, "\\end{document}")
end
```

```@setup ex1
run(`latexmk -quiet -pdf alpha2.tex`)
run(`pdf2svg alpha2.pdf alpha2.svg`)
```

![](alpha2.svg)

### Joining tables

In some occasions, instead of/in addition to showing individual results, we show
a table with the result of multiple solvers.

```@example ex1
df = join(stats, [:f, :t])
markdown_table(stdout, df)
```

The column `:id` is used as guide on where to join. In addition, we may have
repeated columns between the solvers. We convery that information with argument `invariant_cols`.

```@example ex1
df = join(stats, [:f, :t], invariant_cols=[:name])
markdown_table(stdout, df)
```

`join` also accepts `hdr_override` for changing the column name before appending
`_solver`.

```@example ex1
hdr_override = Dict(:name => "Name", :f => "f(x)", :t => "Time")
df = join(stats, [:f, :t], invariant_cols=[:name], hdr_override=hdr_override)
markdown_table(stdout, df)
```

```@example ex1
hdr_override = Dict(:name => "Name", :f => "\\(f(x)\\)", :t => "Time")
df = join(stats, [:f, :t], invariant_cols=[:name], hdr_override=hdr_override)
open("alpha3.tex", "w") do io
  println(io, "\\documentclass[varwidth=20cm,crop=true]{standalone}")
  println(io, "\\usepackage{longtable}")
  println(io, "\\begin{document}")
  latex_table(io, df)
  println(io, "\\end{document}")
end
```

```@setup ex1
run(`latexmk -quiet -pdf alpha3.tex`)
run(`pdf2svg alpha3.pdf alpha3.svg`)
```

![](alpha3.svg)

## Profiles

Performance profiles are a comparison tool developed by [Dolan and
Moré, 2002](https://link.springer.com/article/10.1007/s101070100263) that takes into
account the relative performance of a solver and whether it has achieved convergence for each
problem. `SolverBenchmark.jl` uses
[BenchmarkProfiles.jl](https://github.com/JuliaSmoothOptimizers/BenchmarkProfiles.jl)
for generating performance profiles from the dictionary of `DataFrame`s.

The basic usage is `performance_profile(stats, cost)`, where `cost` is a function
applied to a `DataFrame` and returning a vector.

```@example ex1
using Plots
pyplot()

p = performance_profile(stats, df -> df.t)
Plots.svg(p, "profile1")
```

![](profile1.svg)

Notice that we used `df -> df.t` which corresponds to the column `:t` of the
`DataFrame`s.
This does not take into account that the solvers have failed for a few problems
(according to column :status). The next profile takes that into account.

```@example ex1
cost(df) = (df.status .!= :success) * Inf + df.t
p = performance_profile(stats, cost)
Plots.svg(p, "profile2")
```

![](profile2.svg)

### Profile wall

Another profile function is `profile_solvers`, which creates a wall of performance
profiles, accepting multiple costs and doing 1 vs 1 comparisons in addition to the
traditional performance profile.

```@example ex1
solved(df) = (df.status .== :success)
costs = [df -> .!solved(df) * Inf + df.t, df -> .!solved(df) * Inf + df.iter]
costnames = ["Time", "Iterations"]
p = profile_solvers(stats, costs, costnames)
Plots.svg(p, "profile3")
```

![](profile3.svg)
