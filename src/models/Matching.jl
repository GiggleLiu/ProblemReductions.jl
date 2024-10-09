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

# constraints interface
function hard_constraints(c::Matching)
    # edges sharing a vertex cannot be both in the matching
    return [LocalConstraint([i for (i, e) in enumerate(edges(c.graph)) if contains(e, v)], :noshare) for v in vertices(c.graph)]
end

function is_satisfied(::Type{<:Matching}, spec::LocalConstraint, config)
    @assert length(config) == num_variables(spec)
    return count(isone, config) <= 1
end

function energy_terms(c::Matching)
    # as many edges as possible
    return [LocalConstraint([e], :edge) for e in variables(c)]
end

function local_energy(::Type{<:Matching{T}}, spec::LocalConstraint, config) where {T}
    @assert length(config) == num_variables(spec) == 1
    return T(config[])
end

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