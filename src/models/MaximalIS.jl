"""
$TYPEDEF

The [maximal independent set]problem. 
In the constructor, `weights` are the weights of vertices.

Positional arguments
-------------------------------
* `graph` is the problem graph.
* `weights` are associated with the vertices of the `graph`.
"""
struct MaximalIS{T, WT<:AbstractVector{T}} <: ConstraintSatisfactionProblem{T}
    graph::SimpleGraph
    weights::WT
    function MaximalIS(g::SimpleGraph, weights::AbstractVector{T}=UnitWeight(nv(g))) where {T}
        @assert weights isa UnitWeight || length(weights) == nv(g)
        new{T, typeof(weights)}(g, weights)
    end
end
Base.:(==)(a::MaximalIS, b::MaximalIS) = a.graph == b.graph && a.weights == b.weights

# variables interface
variables(gp::MaximalIS) = [1:nv(gp.graph)...]
num_variables(gp::MaximalIS) = nv(gp.graph)
flavors(::Type{<:MaximalIS}) = [0, 1]
problem_size(c::MaximalIS) = (; num_vertices=nv(c.graph), num_edges=ne(c.graph))

# weights interface
weights(c::MaximalIS) = c.weights
set_weights(c::MaximalIS, weights) = MaximalIS(c.graph, weights)

function hard_constraints(c::MaximalIS)
    return [LocalConstraint(vcat(v, neighbors(c.graph, v)), :maximal_independent) for v in vertices(c.graph)]
end
function is_satisfied(::Type{<:MaximalIS}, spec::LocalConstraint, config)
    @assert length(config) == num_variables(spec)
    nselect = count(!iszero, config)
    return !(nselect == 0 || (nselect > 1 && !iszero(first(config))))
end
# constraints interface
function energy_terms(c::MaximalIS)
    return [LocalConstraint([v], :vertex) for v in vertices(c.graph)]
end
function local_energy(::Type{<:MaximalIS{T}}, spec::LocalConstraint, config) where {T}
    @assert length(config) == num_variables(spec)
    return T(-first(config))
end

"""
    is_maximal_independent_set(g::SimpleGraph, config)

Return true if `config` (a vector of boolean numbers as the mask of vertices) is a maximal independent set of graph `g`.
"""
is_maximal_independent_set(g::SimpleGraph, config) = !any(e->config[e.src] == 1 && config[e.dst] == 1, edges(g)) && all(w->config[w] == 1 || any(v->!iszero(config[v]), neighbors(g, w)), Graphs.vertices(g))