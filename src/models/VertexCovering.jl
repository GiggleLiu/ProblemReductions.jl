"""
$TYPEDEF

Vertex covering is a problem that seeks to find a minimum set of vertices that cover all edges in a graph.

Positional arguments
-------------------------------
* `graph` is a graph object.
* `weights` are associated with the vertices of the `graph`, default to `UnitWeight(nv(graph))`.
"""
struct VertexCovering{T, WT<:AbstractVector{T}} <: ConstraintSatisfactionProblem{T}
    graph::SimpleGraph{Int64}
    weights::WT
    function VertexCovering(graph::SimpleGraph{Int64}, weights::AbstractVector{T}=UnitWeight(nv(graph))) where {T}
        @assert length(weights) == nv(graph) "length of weights must be equal to the number of vertices $(nv(graph)), got: $(length(weights))"
        new{T, typeof(weights)}(graph, weights)
    end
end
Base.:(==)(a::VertexCovering, b::VertexCovering) = a.graph == b.graph && a.weights == b.weights

# variables interface
variables(gp::VertexCovering) = collect(1:nv(gp.graph))
num_variables(gp::VertexCovering) = nv(gp.graph)
flavors(::Type{<:VertexCovering}) = [0, 1] # whether the vertex is selected (1) or not (0)
problem_size(c::VertexCovering) = (; num_vertices=nv(c.graph), num_edges=ne(c.graph))

#weights interface 
weights(c::VertexCovering) = c.weights
set_weights(c::VertexCovering, weights) = VertexCovering(c.graph, weights)

# constraints interface
function hard_constraints(c::VertexCovering)
    return [LocalConstraint(_vec(e), :cover) for e in edges(c.graph)]
end
function is_satisfied(::Type{<:VertexCovering}, spec::LocalConstraint, config)
    @assert length(config) == num_variables(spec)
    return any(!iszero, config)
end
function energy_terms(c::VertexCovering)
    return [LocalConstraint([v], :vertex) for v in vertices(c.graph)]
end
function local_energy(::Type{<:VertexCovering{T}}, spec::LocalConstraint, config) where T
    @assert length(config) == num_variables(spec)
    return T(first(config))
end

"""
    is_vertex_covering(graph::SimpleGraph, config)
return true if the vertex configuration `config` is a vertex covering of the graph.
Our judgement is based on the fact that for each edge, at least one of its vertices is selected.
"""
function is_vertex_covering(graph::SimpleGraph, config)
    @assert length(config) == nv(graph)
    for e in edges(graph)
        config[e.src] == 0 && config[e.dst] == 0 && return false
    end
    return true
end