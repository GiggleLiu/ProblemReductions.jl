"""
$TYPEDEF

The [independent set problem](https://queracomputing.github.io/GenericTensorNetworks.jl/dev/generated/IndependentSet/) in graph theory.

Positional arguments
-------------------------------
* `graph` is the problem graph.
* `weights` are associated with the vertices of the `graph`.

This type of problem currently doesn't have weights.
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

"""
    evaluate(c::IndependentSet, config)

Firstly, we count the edges connecting the input 'config' (a subset of vertices):
If this number is zero, this 'config' corresponds to an Independent Set.
* If the 'config' is an independent set, we return - (size(independent set));
* If the 'config' is not an independent set, we return Inf.
"""

function evaluate(c::IndependentSet, config)
    @assert length(config) == num_variables(c)
    num_ill_edges = count(e -> config[e.src] == 1 && config[e.dst] == 1, edges(c.graph))
    if num_ill_edges == 0
        return - count(x -> x == 1, config)
    else
        return Inf
    end
end