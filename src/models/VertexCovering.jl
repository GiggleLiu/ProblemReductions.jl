"""
$TYPEDEF

Vertex covering is a problem that seeks to find a minimum set of vertices that cover all edges in a graph.

Positional arguments
-------------------------------
* `graph` is a graph object.
* `weights` are associated with the edges of the `graph`, default to `UnitWeight(nv(graph))`.
"""
struct VertexCovering{WT<:AbstractVector} <: AbstractProblem
    graph::SimpleGraph{Int64}
    weights::WT
    function VertexCovering(graph::SimpleGraph{Int64}, weights::AbstractVector=UnitWeight(ne(graph)))
        @assert length(weights) == ne(graph) "length of weights must be equal to the number of edges $(ne(graph)), got: $(length(weights))"
        new{typeof(weights)}(graph, weights)
    end
end
Base.:(==)(a::VertexCovering, b::VertexCovering) = a.graph == b.graph && a.weights == b.weights

# variables interface
variables(gp::VertexCovering) = collect(1:nv(gp.graph))
num_variables(gp::VertexCovering) = nv(gp.graph)
flavors(::Type{<:VertexCovering}) = [0, 1] # whether the vertex is selected (1) or not (0)

#weights interface 
parameters(c::VertexCovering) = c.weights
set_parameters(c::VertexCovering, weights) = VertexCovering(c.graph, weights)

"""
    evaluate(c::VertexCovering, config)
return the total weights of edge that is covered but return typemax(eltype(weights)) if the edge is not covered.
`config` is a vector of boolean numbers.
"""
function evaluate(c::VertexCovering, config)
    @assert length(config) == nv(c.graph)
    vertex_covering_energy(c.graph, c.weights, config)
end

function vertex_covering_energy(g::SimpleGraph, weights::AbstractVector, config)
    !is_vertex_covering(g, config) && return typemax(eltype(weights))
    return sum(weights[i] for i=1:length(weights))
end

"""
    is_vertex_covering(graph::SimpleGraph, config)
return true if the vertex configuration `config` is a vertex covering of the graph.
"""
function is_vertex_covering(graph::SimpleGraph, config)
    @assert length(config) == nv(graph)
    for e in edges(graph)
        config[e.src] == 0 && config[e.dst] == 0 && return false
    end
    return true
end