"""
$TYPEDEF

The [Vertex matching](https://queracomputing.github.io/GenericTensorNetworks.jl/dev/generated/Matching/) problem.

Positional arguments
-------------------------------
- `graph` is the problem graph.
- `weights` are associated with the edges of the `graph`.
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

num_flavors(::Type{<:Matching}) = 2
num_variables(gp::Matching) = ne(gp.graph)
problem_size(c::Matching) = (; num_vertices=nv(c.graph), num_edges=ne(c.graph))

# weights interface
weights(c::Matching) = c.weights
set_weights(c::Matching, weights) = Matching(c.graph, weights)

# constraints interface
function constraints(c::Matching)
    # edges sharing a vertex cannot be both in the matching
    return [LocalConstraint(num_flavors(c), [i for (i, e) in enumerate(edges(c.graph)) if contains(e, v)], [_is_satisfied_noshare(config) for config in combinations(num_flavors(c), length([i for (i, e) in enumerate(edges(c.graph)) if contains(e, v)]))]) for v in vertices(c.graph)]
end
function _is_satisfied_noshare(config)
    return count(isone, config) <= 1
end

function objectives(c::Matching)
    # as many edges as possible
    return [LocalSolutionSize(num_flavors(c), [i], [zero(w), w]) for (i, w) in enumerate(weights(c))]
end
energy_mode(::Type{<:Matching}) = LargerSizeIsBetter()

"""
    is_matching(graph::SimpleGraph, config)

Returns true if `config` is a valid matching on `graph`, and `false` if a vertex is double matched.
`config` is a vector of boolean variables, which has one to one correspondence with `edges(graph)`.
"""
function is_matching(g::SimpleGraph, config)
    @assert ne(g) == length(config)
    edges_mask = zeros(Bool, nv(g))
    for (e, c) in zip(edges(g), config)
        if !iszero(c)
            if edges_mask[e.src]
                return false
            end
            if edges_mask[e.dst]
                return false
            end
            edges_mask[e.src] = true
            edges_mask[e.dst] = true
        end
    end
    return true
end