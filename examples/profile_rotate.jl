using DataFrames, Plots, Printf, SolverBenchmark

nproblems = 20
ids = 1:nproblems
names = [@sprintf("prob%03d", i) for i in ids]

# Three synthetic solvers with different scaling across problems.
t_alpha = [0.10 + 0.012 * i for i in ids]
t_beta = [0.08 + 0.016 * i for i in ids]
t_gamma = [0.12 + 0.010 * i for i in ids]

iter_alpha = [8 + (i % 5) for i in ids]
iter_beta = [7 + (i % 7) for i in ids]
iter_gamma = [9 + (i % 4) for i in ids]

status_alpha = [i % 11 == 0 ? :exception : :first_order for i in ids]
status_beta = [i % 13 == 0 ? :exception : :first_order for i in ids]
status_gamma = [i % 17 == 0 ? :exception : :first_order for i in ids]

stats = Dict(
  :alpha => DataFrame(id = ids, name = names, status = status_alpha, t = t_alpha, iter = iter_alpha),
  :beta => DataFrame(id = ids, name = names, status = status_beta, t = t_beta, iter = iter_beta),
  :gamma => DataFrame(id = ids, name = names, status = status_gamma, t = t_gamma, iter = iter_gamma),
)

costs = [
  df -> (df.status .!= :first_order) * Inf + df.t,
  df -> (df.status .!= :first_order) * Inf + df.iter,
]
costnames = ["Elapsed time", "Iterations"]

p_false = profile_solvers(stats, costs, costnames; rotate = false, width = 450, height = 320)
p_true = profile_solvers(stats, costs, costnames; rotate = true, width = 450, height = 320)

outdir = joinpath(@__DIR__, "generated")
mkpath(outdir)
out_false = joinpath(outdir, "profile_rotate_false.png")
out_true = joinpath(outdir, "profile_rotate_true.png")

savefig(p_false, out_false)
savefig(p_true, out_true)

println("Saved rotate=false plot: " * out_false)
println("Saved rotate=true  plot: " * out_true)
println("rotate=false layout: " * string(size(p_false.layout.grid)))
println("rotate=true  layout: " * string(size(p_true.layout.grid)))
