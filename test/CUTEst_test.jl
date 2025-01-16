using SolverCore
using CUTEst

import SolverCore.dummy_solver

function test_cutest()
  problem_names =
    CUTEst.select(min_con = 1, max_con = 3, max_var = 3, only_equ_con = true, only_free_var = true)[1:5]
  problem_list = (CUTEstModel(name) for name in problem_names)
  solvers = Dict(:dummy_1 => dummy_solver, :dummy_2 => dummy_solver)
  stats = bmark_solvers(solvers, problem_list, use_threads = true)
end

test_cutest()