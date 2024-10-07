"""
$(TYPEDEF)
    Coloring{K}(graph; weights=UnitWeight(nv(graph)))

The [Vertex Coloring](https://queracomputing.github.io/GenericTensorNetworks.jl/dev/generated/Coloring/) problem.

Positional arguments
-------------------------------
* `graph` is the problem graph.
* `weights` are associated with the edges of the `graph`, default to `UnitWeight(ne(graph))`.
"""
struct Coloring{K, T, WT<:AbstractVector{T}} <: ConstraintSatisfactionProblem{T}
    graph::SimpleGraph{Int64}
    weights::WT
    function Coloring{K}(graph::SimpleGraph{Int64}, weights::AbstractVector{T}=UnitWeight(ne(graph))) where {K, T}
        @assert length(weights) == ne(graph) "length of weights must be equal to the number of edges $(ne(graph)), got: $(length(weights))"
        new{K, T, typeof(weights)}(graph, weights)
    end
end
Base.:(==)(a::Coloring, b::Coloring) = a.graph == b.graph && a.weights == b.weights
problem_size(c::Coloring) = (; num_vertices=nv(c.graph), num_edges=ne(c.graph))

# variables interface
variables(gp::Coloring{K}) where K = collect(1:nv(gp.graph))
flavors(::Type{<:Coloring{K}}) where K = collect(0:K-1) # colors
num_flavors(::Type{<:Coloring{K}}) where K = K # number of colors

# weights interface
weights(c::Coloring) = c.weights
set_weights(c::Coloring{K}, weights) where K = Coloring{K}(c.graph, weights)

# constraints interface
@nohard_constraints Coloring
function energy_terms(c::Coloring)
    # constraints on edges
    return [LocalConstraint(e, :coloring) for e in vedges(c.graph)]
end

function local_energy(::Type{<:Coloring{K, T}}, spec::LocalConstraint, config) where {K, T}
    @assert length(config) == num_variables(spec)
    return config[1] == config[2] ? one(T) : zero(T)
end

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

