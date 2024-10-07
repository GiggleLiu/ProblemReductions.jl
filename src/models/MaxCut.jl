"""
$TYPEDEF

The [cutting](https://queracomputing.github.io/GenericTensorNetworks.jl/dev/generated/MaxCut/) problem.
* In this problem, we would like to find the cut of the graph that maximizes the sum of the 
weights of the edges that are cut.

Positional arguments
-------------------------------
* `graph` is the problem graph.
* `weights` are associated with the edges of the `graph`. We have ensure that the `weights` are in the same order as the edges in `edges(graph)`.
"""
struct MaxCut{T, WT<:AbstractVector{T}} <: ConstraintSatisfactionProblem{T}
    graph::SimpleGraph{Int}
    weights::WT
    function MaxCut(g::SimpleGraph,weights::AbstractVector{T}=UnitWeight(ne(g))) where {T}
        @assert length(weights) == ne(g) "got $(length(weights)) weights, but $(ne(g)) are required"
        new{T, typeof(weights)}(g, weights)
    end
end
Base.:(==)(a::MaxCut, b::MaxCut) = a.graph == b.graph && a.weights == b.weights

# varibles interface 
variables(gp::MaxCut) = [1:nv(gp.graph)...]
num_variables(gp::MaxCut) = nv(gp.graph)
flavors(::Type{<:MaxCut}) = [0, 1] #choose it or not
problem_size(c::MaxCut) = (; num_vertices=nv(c.graph), num_edges=ne(c.graph))
                            
# weights interface
weights(c::MaxCut) = c.weights
set_weights(c::MaxCut, weights) = MaxCut(c.graph, weights)

# constraints interface
function energy_terms(c::MaxCut)
    return [LocalConstraint(e, :cut) for e in vedges(c.graph)]
end
function local_energy(::Type{<:MaxCut{T}}, spec::LocalConstraint, config) where {T}
    @assert length(config) == num_variables(spec)
    return (config[1] != config[2]) ? -one(T) : zero(T)
end
@nohard_constraints MaxCut

function cut_size(terms, config; weights=UnitWeight(length(terms)))
    size = zero(promote_type(eltype(weights)))
    for (i,j) in zip(terms, weights)
        size += (config[i[1]] != config[i[2]]) * j  # terms are the edges,and terms[1],terms[2] are the two vertices of the edge.
    end
    return size
end


