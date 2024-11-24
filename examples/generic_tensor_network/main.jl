using GenericTensorNetworks

# create a random King's subgraph
graph = random_diagonal_coupled_graph(7, 7, 0.8)
# create an independent set problem
problem = GenericTensorNetworks.IndependentSet(graph)
# convert to tensor network
pb = GenericTensorNetwork(problem)

# solve the MIS size
res_size = solve(pb, SizeMax())[]

# solve the MIS counting
res_count = solve(pb, CountingMax(2))[]

# obtain the MIS configurations
res_configs = solve(pb, ConfigsMax(2; tree_storage=true))[]

# visualize the landscape
show_landscape((x, y)->hamming_distance(x, y) <= 2, res_configs; layout_method=:spring)