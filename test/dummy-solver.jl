using NLPModels, SolverCore

# non-allocating reshape
# see https://github.com/JuliaLang/julia/issues/36313
reshape_array(a, dims) = invoke(Base._reshape, Tuple{AbstractArray, typeof(dims)}, a, dims)

mutable struct DummySolver{S} <: AbstractOptimizationSolver
  x::S     # primal approximation
  gx::S    # gradient of objective
  y::S     # multipliers estimates
  rhs::S   # right-hand size of Newton system
  jval::S  # flattened Jacobian
  hval::S  # flattened Hessian
  wval::S  # flattened augmented matrix
  Δxy::S   # search direction
end

function DummySolver(nlp::AbstractNLPModel{T, S}) where {T, S <: AbstractVector{T}}
  nvar, ncon = nlp.meta.nvar, nlp.meta.ncon
  x = similar(nlp.meta.x0)
  gx = similar(nlp.meta.x0)
  y = similar(nlp.meta.y0)
  rhs = similar(nlp.meta.x0, nvar + ncon)
  jval = similar(nlp.meta.x0, ncon * nvar)
  hval = similar(nlp.meta.x0, nvar * nvar)
  wval = similar(nlp.meta.x0, (nvar + ncon) * (nvar + ncon))
  Δxy = similar(nlp.meta.x0, nvar + ncon)
  DummySolver{S}(x, gx, y, rhs, jval, hval, wval, Δxy)
end

function dummy(
  nlp::AbstractNLPModel{T, S},
  args...;
  kwargs...,
) where {T, S <: AbstractVector{T}}
  solver = DummySolver(nlp)
  stats = GenericExecutionStats(nlp)
  solve!(solver, nlp, stats, args...; kwargs...)
end

function solve!(
  solver::DummySolver{S},
  nlp::AbstractNLPModel{T, S},
  stats::GenericExecutionStats;
  callback = (args...) -> nothing,
  x0::S = nlp.meta.x0,
  atol::Real = sqrt(eps(T)),
  rtol::Real = sqrt(eps(T)),
  max_eval::Int = 1000,
  max_time::Float64 = 30.0,
  verbose::Bool = true,
) where {T, S <: AbstractVector{T}}
  start_time = time()
  elapsed_time = 0.0
  set_time!(stats, elapsed_time)

  nvar, ncon = nlp.meta.nvar, nlp.meta.ncon
  x = solver.x .= x0
  rhs = solver.rhs
  dual = view(rhs, 1:nvar)
  cx = view(rhs, (nvar + 1):(nvar + ncon))
  gx = solver.gx
  y = solver.y
  jval = solver.jval
  hval = solver.hval
  wval = solver.wval
  Δxy = solver.Δxy
  nnzh = Int(nvar * (nvar + 1) / 2)
  nnzh == nlp.meta.nnzh || error("solver assumes Hessian is dense")
  nvar * ncon == nlp.meta.nnzj || error("solver assumes Jacobian is dense")

  grad!(nlp, x, gx)
  dual .= gx

  # assume the model returns a dense Jacobian in column-major order
  if ncon > 0
    cons!(nlp, x, cx)
    jac_coord!(nlp, x, jval)
    Jx = reshape_array(jval, (ncon, nvar))
    Jqr = qr(Jx')

    # compute least-squares multipliers
    # by solving Jx' y = -gx
    gx .*= -1
    ldiv!(y, Jqr, gx)

    # update dual <- dual + Jx' * y
    mul!(dual, Jx', y, one(T), one(T))
  end

  iter = 0
  set_iter!(stats, iter)
  ϵd = atol + rtol * norm(dual)
  ϵp = atol

  fx = obj(nlp, x)
  set_objective!(stats, fx)
  verbose && @info log_header([:iter, :f, :c, :dual, :t, :x], [Int, T, T, T, Float64, Char])
  verbose && @info log_row(Any[iter, fx, norm(cx), norm(dual), elapsed_time, 'c'])
  solved = norm(dual) < ϵd && norm(cx) < ϵp

  set_status!(
    stats,
    get_status(
      nlp,
      elapsed_time = elapsed_time,
      iter = iter,
      optimal = solved,
      max_eval = max_eval,
      max_time = max_time,
    ),
  )

  while stats.status == :unknown
    # assume the model returns a dense Hessian in column-major order
    # NB: hess_coord!() only returns values in the lower triangle
    hess_coord!(nlp, x, y, view(hval, 1:nnzh))

    # rearrange nonzeros so they correspond to a dense nvar x nvar matrix
    j = nvar * nvar
    i = nnzh
    k = 1
    while i > nvar
      for _ = 1:k
        hval[j] = hval[i]
        hval[i] = 0
        j -= 1
        i -= 1
      end
      j -= nvar - k
      k += 1
    end

    # fill in augmented matrix
    # W = [H J']
    #     [J 0 ]
    wval .= 0
    Wxy = reshape_array(wval, (nvar + ncon, nvar + ncon))
    Hxy = reshape_array(hval, (nvar, nvar))
    Wxy[1:nvar, 1:nvar] .= Hxy
    for i = 1:nvar
      Wxy[i, i] += sqrt(eps(T))
    end
    if ncon > 0
      Wxy[(nvar + 1):(nvar + ncon), 1:nvar] .= Jx
    end
    LBL = factorize(Symmetric(Wxy, :L))

    ldiv!(Δxy, LBL, rhs)
    Δxy .*= -1
    @views Δx = Δxy[1:nvar]
    @views Δy = Δxy[(nvar + 1):(nvar + ncon)]
    x .+= Δx
    y .+= Δy

    grad!(nlp, x, gx)
    dual .= gx
    if ncon > 0
      cons!(nlp, x, cx)
      jac_coord!(nlp, x, jval)
      Jx = reshape_array(jval, (ncon, nvar))
      Jqr = qr(Jx')
      gx .*= -1
      ldiv!(y, Jqr, gx)
      mul!(dual, Jx', y, one(T), one(T))
    end
    elapsed_time = time() - start_time
    set_time!(stats, elapsed_time)
    presid = norm(cx)
    dresid = norm(dual)
    set_residuals!(stats, presid, dresid)
    solved = dresid < ϵd && presid < ϵp

    iter += 1
    fx = obj(nlp, x)
    set_iter!(stats, iter)
    set_objective!(stats, fx)

    set_status!(
      stats,
      get_status(
        nlp,
        elapsed_time = elapsed_time,
        iter = iter,
        optimal = solved,
        max_eval = max_eval,
        max_time = max_time,
      ),
    )

    callback(nlp, solver, stats)

    verbose && @info log_row(Any[iter, fx, norm(cx), norm(dual), elapsed_time, 'd'])
  end

  set_residuals!(stats, norm(cx), norm(dual))
  z = has_bounds(nlp) ? zeros(T, nvar) : zeros(T, 0)
  set_multipliers!(stats, y, z, z)
  set_solution!(stats, x)
  return stats
end
