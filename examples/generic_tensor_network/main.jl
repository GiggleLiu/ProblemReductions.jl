using GenericTensorNetworks

graph = random_diagonal_coupled_graph(7, 7, 0.8)
problem = IndependentSet(graph)  # Independent set problem
pb = GenericTensorNetwork(problem)  # Convert to tensor network

res_size = solve(pb, SizeMax())[]  # MIS size

res_count = solve(pb, CountingMax(2))[]  # Counting of independent sets with largest 2 sizes

res_configs = solve(pb, ConfigsMax(2; tree_storage=true))[]  # The corresponding configurations
show_landscape((x, y)->hamming_distance(x, y) <= 2, res_configs; layout_method=:spring)