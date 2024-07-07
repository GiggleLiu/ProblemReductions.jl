using GenericTensorNetworks, Random

graph = random_diagonal_coupled_graph(7, 7, 0.8)
problem = IndependentSet(graph)  # Independent set problem
pb = GenericTensorNetwork(problem)  # Convert to tensor network

res_size = solve(pb, SizeMax())[]  # MIS size

res_count = solve(pb, CountingMax(2))[]  # Counting of independent sets with largest 2 sizes

res_configs = solve(pb, ConfigsMax(2; tree_storage=true))[]  # The corresponding configurations
show_landscape((x, y)->hamming_distance(x, y) <= 2, res_configs; layout_method=:spring)



# set seed
seed = 2
Random.seed!(seed)

# setup graph
n = 7
graph = random_diagonal_coupled_graph(n, n, 0.8)
# graph = random_regular_graph(n, 3)
# res = map_factoring(n, n); graph, weights = graph_and_weights(res.grid_graph)
@info "Number of nodes: $(nv(graph))"
show_graph(graph, SpringLayout(; optimal_distance=20))

# setup problem
problem = IndependentSet(graph)

K = 2
show_landscape(problem; K)
viz_hamming_stats(problem; K)