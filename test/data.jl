function get_stats_data()
  n = 10
  names = [:alpha, :beta, :gamma]
  stats = Dict(
    name => DataFrame(
      :id => 1:n,
      :name => [@sprintf("prob%03d", i) for i = 1:n],
      :status => map(x -> mod(x, 3) == 0 ? :first_order : :failure, 1:n),
      :f => [exp(i / n) for i = 1:n],
      :t => [1e-3 .+ abs(sin(2π * i / n)) * 1000 for i = 1:n],
      :iter => [3 + 2 * Int(ceil(sin(2π * i / n))) for i = 1:n],
      :irrelevant => collect(1:n),
    ) for name in names
  )
  return stats
end
