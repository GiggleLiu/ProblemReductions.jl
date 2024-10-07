"""
$TYPEDEF

The [Vertex matching](https://queracomputing.github.io/GenericTensorNetworks.jl/dev/generated/Matching/) problem.

Positional arguments
-------------------------------
* `graph` is the problem graph.
* `weights` are associated with the edges of the `graph`.
"""
struct Matching{T, WT<:AbstractVector{T}} <: ConstraintSatisfactionProblem{T}
    graph::SimpleGraph{Int}
    weights::WT
    function Matching(g::SimpleGraph, weights::AbstractVector{T}=UnitWeight(ne(g))) where {T}
        @assert length(weights) == ne(g)
        new{T, typeof(weights)}(g, weights)
    end
end
Base.:(==)(a::Matching, b::Matching) = a.graph == b.graph && a.weights == b.weights

flavors(::Type{<:Matching}) = [0, 1]
variables(gp::Matching) = collect(1:ne(gp.graph))
num_variables(gp::Matching) = ne(gp.graph)
problem_size(c::Matching) = (; num_vertices=nv(c.graph), num_edges=ne(c.graph))

# weights interface
weights(c::Matching) = c.weights
set_weights(c::Matching, weights) = Matching(c.graph, weights)

function energy(c::Matching, config)
    @assert length(config) == ne(c.graph)
    if !is_matching(c.graph, config)
        return Inf
    end
    return sum(i -> config[i]*c.weights[i], 1:ne(c.graph))
end

"""
    is_matching(graph::SimpleGraph, config)

Returns true if `config` is a valid matching on `graph`, and `false` if a vertex is double matched.
`config` is a vector of boolean variables, which has one to one correspondence with `edges(graph)`.
"""
function is_matching(g::SimpleGraph, config)
    @assert ne(g) == length(config)
    edges_mask = zeros(Bool, nv(g))
    for (e, c) in zip(vedges(g), config)
        if !iszero(c)
            if edges_mask[e[1]]
                return false
            end
            if edges_mask[e[2]]
                return false
            end
            edges_mask[e[1]] = true
            edges_mask[e[2]] = true
        end
    end
    return true
end