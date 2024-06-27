using GenericTensorNetworks, Random, Graphs
using UnitDiskMapping
using CairoMakie

"""
    viz_landscape(problem; K=2)

Visualize the landscape of the given problem.

# Arguments
- `problem`: The problem to visualize.
- `K`: The number of lowest energy levels to visualize.
"""
function viz_landscape(problem; K=2)
    pb = GenericTensorNetwork(problem)
    res = solve(pb, ConfigsMax(K))[]
    sc = read_size_configs(res)
    configs = vcat([c.second for c in sc]...)
    @info "Number of configurations: $(length(configs))"
    length(configs) > 20000 && error("Too many configurations")
    show_landscape((x, y)->hamming_distance(x, y) <= 2, res; layout_method=:spring)
end

"""
    viz_hamming_stats(problem; K=2)

Visualize the hamming distance statistics of the given problem.

# Arguments
- `problem`: The problem to visualize.
- `K`: The number of lowest energy levels to visualize.
"""
function viz_hamming_stats(problem; K=2)
    pb = GenericTensorNetwork(problem)
    tree = solve(pb, ConfigsMax(K; tree_storage=true))[]
    tree = sum([c for c in tree.coeffs])
    samples1 = generate_samples(tree, 10000)
    samples2 = generate_samples(tree, 10000)
    stats = hamming_distribution(samples1, samples2)
    # bar plot
    fig = Figure()
    ax = Axis(fig[1, 1]; yscale=log10, xlabel="Hamming distance", ylabel="Frequency", xlabelsize=18, ylabelsize=18)
    barplot!(ax, 0:length(stats)-1, stats)
    fig
end

function show_ksg(n::Int, seed::Int)
    Random.seed!(seed)
    mask = GenericTensorNetworks.generate_mask(n, n, round(Int, n^2*0.8))
    gg = GridGraph([SimpleCell(; occupied=m) for m in mask], 1.9)
    show_graph(gg; config=GraphDisplayConfig(; vertex_size=8))
end