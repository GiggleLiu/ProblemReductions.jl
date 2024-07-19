"""
$(TYPEDEF)
    Coloring{K}(graph; weights=UnitWeight(nv(graph)))

The [Vertex Coloring](https://queracomputing.github.io/GenericTensorNetworks.jl/dev/generated/Coloring/) problem.

Positional arguments
-------------------------------
* `graph` is the problem graph.
* `weights` are associated with the edges of the `graph`, default to `UnitWeight(nv(graph))`.
"""
struct Coloring{K, WT<:AbstractVector} <:AbstractProblem
    graph::SimpleGraph{Int64}
    weights::WT
    function Coloring{K}(graph::SimpleGraph{Int64}, weights::AbstractVector=UnitWeight(nv(graph))) where {K}
        @assert length(weights) == ne(graph) "length of weights must be equal to the number of edges $(ne(graph)), got: $(length(weights))"
        new{K, typeof(weights)}(graph, weights)
    end
end
Base.:(==)(a::Coloring, b::Coloring) = a.graph == b.graph && a.weights == b.weights

# variables interface
variables(gp::Coloring{K}) where K = collect(1:nv(gp.graph))
flavors(::Type{<:Coloring{K}}) where K = collect(0:K-1) # colors
num_flavors(::Type{<:Coloring{K}}) where K = K # number of colors

# weights interface
parameters(c::Coloring) = c.weights
set_parameters(c::Coloring{K}, weights) where K = Coloring{K}(c.graph, weights)

# utilities
"""
    evaluate(c::Coloring, config)

Compute the energy of the vertex coloring configuration `config`, the energy is the number of violated edges.
"""
function evaluate(c::Coloring, config)
    @assert length(config) == nv(c.graph)
    coloring_energy(vedges(c.graph), c.weights,config)
end

coloring_energy(terms::AbstractVector, weights::AbstractVector, config) = sum(ew->(config[ew[1][1]] == config[ew[1][2]]) * ew[2], zip(terms, weights))


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

