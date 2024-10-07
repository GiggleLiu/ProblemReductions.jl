"""
$(TYPEDEF)
    DominatingSet(graph::AbstractGraph, weights::AbstractVector=UnitWeight(ne(graph))) -> DominatingSet

Represents the [dominating set](https://queracomputing.github.io/GenericTensorNetworks.jl/dev/generated/DominatingSet/) problem.

Positional arguments
-------------------------------
* `graph` is the problem graph.
* `weights::AbstractVector`: Weights associated with the vertices of the `graph`. Defaults to `UnitWeight(nv(graph))`.
"""
struct DominatingSet{GT<:AbstractGraph, T, WT<:AbstractVector{T}} <: ConstraintSatisfactionProblem{T}
    graph::GT
    weights::WT
    function DominatingSet(graph::AbstractGraph, weights::AbstractVector{T}=UnitWeight(nv(graph))) where {T}
        return new{typeof(graph), T, typeof(weights)}(graph, weights)
    end
end
Base.:(==)(a::DominatingSet, b::DominatingSet) = ( a.graph == b.graph )

# Variables Interface
variables(gp::DominatingSet) = [1:nv(gp.graph)...]
flavors(::Type{<:DominatingSet}) = [0, 1]
problem_size(c::DominatingSet) = (; num_vertices=nv(c.graph), num_edges=ne(c.graph))

# Weights Interface
weights(c::DominatingSet) = c.weights
set_weights(c::DominatingSet, weights) = DominatingSet(c.graph, weights)

# Constraints Interface
@nohard_constraints DominatingSet
function energy_terms(c::DominatingSet)
    # constraints on vertex and its neighbours
    return [LocalConstraint(vcat(v, neighbors(c.graph, v)), :dominating) for v in vertices(c.graph)]
end

function local_energy(::Type{<:DominatingSet{GT, T}}, spec::LocalConstraint, config) where {GT, T}
    @assert length(config) == num_variables(spec)
    nselect = count(isone, config)
    return nselect < 1 ? energy_max(T) : T(config[1])
end