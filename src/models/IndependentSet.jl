"""
$(TYPEDEF)
    IndependentSet(graph::AbstractGraph, weights::AbstractVector=UnitWeight(nv(graph))) -> IndependentSet

Represents the [independent set problem](https://queracomputing.github.io/GenericTensorNetworks.jl/dev/generated/IndependentSet/) in graph theory.

Positional arguments
-------------------------------
- `graph::AbstractGraph`: The problem graph.
- `weights::AbstractVector`: Weights associated with the vertices of the `graph`. Defaults to `UnitWeight(nv(graph))`.
"""
struct IndependentSet{GT<:AbstractGraph, WT<:AbstractVector} <: AbstractProblem
    graph::GT
    weights::WT
    function IndependentSet(graph::AbstractGraph, weights::AbstractVector=UnitWeight(nv(graph)))
        return new{typeof(graph), typeof(weights)}(graph, weights)
    end
end
Base.:(==)(a::IndependentSet, b::IndependentSet) = ( a.graph == b.graph )

# Variables Interface
variables(gp::IndependentSet) = [1:nv(gp.graph)...]
flavors(::Type{<:IndependentSet}) = [0, 1]
problem_size(c::IndependentSet) = (; num_vertices=nv(c.graph), num_edges=ne(c.graph))

"""
    evaluate(c::IndependentSet, config)

Count the edges connecting the input 'config' (a subset of vertices). 
If this number is zero, this 'config' corresponds to an Independent Set.
Otherwise, these edges would violate the definition of independent set.
* If the 'config' is an independent set, we return - (size(independent set));
* If the 'config' is not an independent set, we return 0.
"""
function evaluate(c::IndependentSet, config)
    @assert length(config) == num_variables(c)
    num_ill_edges = count(e -> count(v -> config[v] == 1, _vec(e)) > 1, edges(c.graph))
    if num_ill_edges == 0
        return - count(x -> x == 1, config)
    else
        return 0
    end
end