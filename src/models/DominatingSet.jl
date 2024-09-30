"""
$(TYPEDEF)
    DominatingSet(graph::AbstractGraph, weights::AbstractVector=UnitWeight(ne(graph))) -> DominatingSet

Represents the [dominating set](https://queracomputing.github.io/GenericTensorNetworks.jl/dev/generated/DominatingSet/) problem.

Positional arguments
-------------------------------
* `graph` is the problem graph.
* `weights::AbstractVector`: Weights associated with the vertices of the `graph`. Defaults to `UnitWeight(nv(graph))`.
"""
struct DominatingSet{ GT<:AbstractGraph, WT<:AbstractVector} <: AbstractProblem
    graph::GT
    weights::WT
    function DominatingSet( graph::AbstractGraph, weights::AbstractVector=UnitWeight(nv(graph)))
        return new{typeof(graph), typeof(weights)}(graph, weights)
    end
end
Base.:(==)(a::DominatingSet, b::DominatingSet) = ( a.graph == b.graph )

# Variables Interface
variables(gp::DominatingSet) = [1:nv(gp.graph)...]
flavors(::Type{<:DominatingSet}) = [0, 1]
problem_size(c::DominatingSet) = (; num_vertices=nv(c.graph), num_edges=ne(c.graph))

"""
    evaluate(c::DominatingSet, config)

Count the number of vertices outside the dominating set and the neighbours of the dominating set. 
When the number is zero, the configuration corresponds to a dominating set. 
* If the configuration is a dominating set return size(dominating set).
* If the configuration is not a dominating set return nv(graph);
"""
function evaluate(c::DominatingSet, config)
    g = c.graph
    num_outside_vertices = count(w -> config[w] == 0 && all(v-> config[v] == 0, neighbors(g, w)), Graphs.vertices(g))
    if num_outside_vertices == 0
        return count(x -> x == 1, config)
    else
        return nv(g)
    end
end