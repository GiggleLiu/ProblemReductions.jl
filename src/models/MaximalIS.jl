"""
$TYPEDEF

The [maximal independent set]problem. 
In the constructor, `weights` are the weights of vertices.

Positional arguments
-------------------------------
* `graph` is the problem graph.
* `weights` are associated with the vertices of the `graph`.
"""
struct MaximalIS{WT<:Union{UnitWeight, Vector}} <: AbstractProblem
    graph::SimpleGraph
    weights::WT
    function MaximalIS(g::SimpleGraph, weights::Union{UnitWeight, Vector}=UnitWeight(nv(g)))
        @assert weights isa UnitWeight || length(weights) == nv(g)
        new{typeof(weights)}(g, weights)
    end
end
Base.:(==)(a::MaximalIS, b::MaximalIS) = a.graph == b.graph && a.weights == b.weights

# variables interface
variables(gp::MaximalIS) = [1:nv(gp.graph)...]
num_variables(gp::MaximalIS) = nv(gp.graph)
flavors(::Type{<:MaximalIS}) = [0, 1]

# weights interface
parameters(c::MaximalIS) = c.weights
set_parameters(c::MaximalIS, weights) = MaximalIS(c.graph, weights)


"""
    evaluate(c::MaximalIS, config)
    Return the weights of the vertices that are not in the maximal independent set.
"""
function evaluate(c::MaximalIS, config)
    @assert length(config) == nv(c.graph)
    if !is_maximal_independent_set(c.graph, config)
        return Inf
    end
    return sum(i -> config[i]*c.weights[i], 1:nv(c.graph))
end

"""
    is_maximal_independent_set(g::SimpleGraph, config)

Return true if `config` (a vector of boolean numbers as the mask of vertices) is a maximal independent set of graph `g`.
"""
is_maximal_independent_set(g::SimpleGraph, config) = !any(e->config[e.src] == 1 && config[e.dst] == 1, edges(g)) && all(w->config[w] == 1 || any(v->!iszero(config[v]), neighbors(g, w)), Graphs.vertices(g))