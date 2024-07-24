"""
$TYPEDEF
    DominatingSet(graph; weights=UnitWeight())

The [dominating set](https://queracomputing.github.io/GenericTensorNetworks.jl/dev/generated/DominatingSet/) problem.

Positional arguments
-------------------------------
* `graph` is the problem graph.

We don't have weights for this problem.
"""
struct DominatingSet{ GT<:AbstractGraph} <: AbstractProblem
    graph::GT
    function DominatingSet( graph::AbstractGraph)
        return new{typeof(graph)}(graph)
    end
end
Base.:(==)(a::DominatingSet, b::DominatingSet) = ( a.graph == b.graph )

# Variables Interface
variables(gp::DominatingSet) = [1:nv(gp.graph)...]
flavors(::Type{<:DominatingSet}) = [0, 1]

"""
    evaluate(c::DominatingSet, config)

Firstly, we count the number of vertices outside the dominating set and the neighbours of the dominating set: 
If this number is zero, this configuration corresponds to a dominating set. 
* If the configuration is not a dominating set return Inf;
* If the configuration is a dominating set return -( size(dominating set) ).
"""

function evaluate(c::DominatingSet, config)
    g = c.graph
    num_outside_vertices = count(w -> config[w] == 0 && all(v-> config[v] == 0, neighbors(g, w)), Graphs.vertices(g))
    if num_outside_vertices == 0
        return - count(x -> x == 1, config)
    else
        return Inf
    end
end