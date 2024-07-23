"""
$TYPEDEF

The [independent set problem](https://queracomputing.github.io/GenericTensorNetworks.jl/dev/generated/IndependentSet/) in graph theory.

Positional arguments
-------------------------------
* `graph` is the problem graph.
* `vertex_weights` are associated with the vertices of the `graph`.

Examples
-------------------------------
Under Development
"""
struct IndependentSet{ GT<:AbstractGraph} <: AbstractProblem
    graph::GT
    function IndependentSet( graph::AbstractGraph)
        return new{typeof(graph)}(graph)
    end
end
Base.:(==)(a::IndependentSet, b::IndependentSet) = ( a.graph == b.graph )

# Variables Interface
variables(gp::IndependentSet) = [1:nv(gp.graph)]
flavors(::Type{<:IndependentSet}) = [0, 1]

"""
    evaluate(c::IndependentSet, config)

Count the edges connecting the input 'config' (a subset of vertices)
"""

function evaluate(c::IndependentSet, config)
    @assert length(config) == num_variables(c)
    return count(e -> config[e.src] == 1 && config[e.dst] == 1, edges(g))
end