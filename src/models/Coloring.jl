"""
$(TYPEDEF)
    Coloring{K}(graph; weights=UnitWeight())

The [Vertex Coloring](https://queracomputing.github.io/GenericTensorNetworks.jl/dev/generated/Coloring/) problem.

Positional arguments
-------------------------------
* `graph` is the problem graph.
* `weights` are associated with the edges of the `graph`, default to `UnitWeight()`.
"""
struct Coloring{K, WT<:Union{UnitWeight, Vector}} <:AbstractProblem
    graph::SimpleGraph{Int64}
    weights::WT
    function Coloring{K}(graph::SimpleGraph{Int64}, weights::Union{UnitWeight, Vector}=UnitWeight()) where {K}
        @assert weights isa UnitWeight || length(weights) == ne(graph) "length of weights must be equal to the number of edges $(ne(graph)), got: $(length(weights))"
        new{K, typeof(weights)}(graph, weights)
    end
end

variables(gp::Coloring) = collect(1:nv(gp.graph))
flavors(::Type{<:Coloring{K}}) where K = collect(0:K-1) # colors
num_flavors(c::Type{<:Coloring{K}}) where K = length(flavors(c)) # number of colors
terms(gp::Coloring) = [[minmax(e.src,e.dst)...] for e in Graphs.edges(gp.graph)] # return the edges of the graph
 

# weights interface
# ?whether weights information would be useful here? I think in sat-coloring, we only need to consider unweighted graphs
get_weights(c::Coloring) = c.weights
get_weights(c::Coloring{K}, i::Int) where K = fill(c.weights[i], K)
chweights(c::Coloring{K}, weights) where K = Coloring{K}(c.graph, weights)

# utilities
"""
    evaluate(c::Coloring, config)

Compute the energy of the vertex coloring configuration `config`, the energy is the number of violated edges.
"""
function evaluate(c::Coloring, config)
    @assert length(config) == nv(c.graph)
    coloring_energy(terms(c), config)
end

coloring_energy(terms::AbstractMatrix, config) = sum([config[e[1]] == config[e[2]] for e in terms])


"""
    is_vertex_coloring(graph::SimpleGraph, config)

Returns true if the coloring specified by config is a valid one, i.e. does not violate the contraints of vertices of an edges having different colors.
"""
function is_vertex_coloring(graph::SimpleGraph, config)
    for e in edges(graph)
        config[e.src] == config[e.dst] && return false
    end
    return true
end

