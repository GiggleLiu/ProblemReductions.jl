"""
$(TYPEDEF)
    IndependentSet(graph::AbstractGraph, weights::AbstractVector=UnitWeight(nv(graph))) -> IndependentSet

Represents the [independent set problem](https://queracomputing.github.io/GenericTensorNetworks.jl/dev/generated/IndependentSet/) in graph theory.

Positional arguments
-------------------------------
- `graph::AbstractGraph`: The problem graph.
- `weights::AbstractVector`: Weights associated with the vertices of the `graph`. Defaults to `UnitWeight(nv(graph))`.
"""
struct IndependentSet{GT<:AbstractGraph, T, WT<:AbstractVector{T}} <: ConstraintSatisfactionProblem{T}
    graph::GT
    weights::WT
    function IndependentSet(graph::AbstractGraph, weights::AbstractVector{T}=UnitWeight(nv(graph))) where {T}
        return new{typeof(graph), T, typeof(weights)}(graph, weights)
    end
end
Base.:(==)(a::IndependentSet, b::IndependentSet) = ( a.graph == b.graph )

# Variables Interface
variables(gp::IndependentSet) = [1:nv(gp.graph)...]
flavors(::Type{<:IndependentSet}) = [0, 1]
problem_size(c::IndependentSet) = (; num_vertices=nv(c.graph), num_edges=ne(c.graph))

# weights interface
weights(c::IndependentSet) = c.weights
set_weights(c::IndependentSet, weights) = IndependentSet(c.graph, weights)

# constraints interface
function hard_constraints(c::IndependentSet)
    return [LocalConstraint(_vec(e), nothing) for e in edges(c.graph)]
end
function is_satisfied(::Type{<:IndependentSet}, spec::LocalConstraint, config)
    @assert length(config) == num_variables(spec)
    return count(!iszero, config) <= 1
end

function energy_terms(c::IndependentSet)
    return [LocalConstraint([i], nothing) for i in 1:nv(c.graph)]
end

function local_energy(::Type{<:IndependentSet{GT, T}}, spec::LocalConstraint, config) where {GT, T}
    @assert length(config) == num_variables(spec) == 1
    return T(-first(config))
end