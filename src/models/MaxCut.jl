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
struct MaxCut{WT<:AbstractVector} <: AbstractProblem
    graph::SimpleGraph{Int}
    weights::WT
    function MaxCut(g::SimpleGraph,weights::AbstractVector=UnitWeight(ne(g))) 
        @assert length(weights) == ne(g) "got $(length(weights)) weights, but $(ne(g)) are required"
        new{typeof(weights)}(g, weights)
    end
end
Base.:(==)(a::MaxCut, b::MaxCut) = a.graph == b.graph && a.weights == b.weights

# varibles interface 
variables(gp::MaxCut) = [1:nv(gp.graph)...]
num_variables(gp::MaxCut) = nv(gp.graph)
flavors(::Type{<:MaxCut}) = [0, 1] #choose it or not
problem_size(c::MaxCut) = (; num_vertices=nv(c.graph), num_edges=ne(c.graph))
                            
# weights interface
parameters(c::MaxCut) = [[c.weights[i] for i=1:ne(c.graph)]...]
set_parameters(c::MaxCut, weights) = MaxCut(c.graph, weights[1:ne(c.graph)])



"""
    evaluate(c::MaxCut, config)
Compute the cut weights for the vertex configuration `config` (an iterator). The energy is the 
sum of the weights of the edges that are cut.
"""
function evaluate(c::MaxCut, config)
    @assert length(config) == nv(c.graph)
    -cut_size(vedges(c.graph), config; weights=c.weights)
end

function cut_size(terms, config; weights=UnitWeight(length(terms)))
    size = zero(promote_type(eltype(weights)))
    for (i,j) in zip(terms, weights)
        size += (config[i[1]] != config[i[2]]) * j  # terms are the edges,and terms[1],terms[2] are the two vertices of the edge.
    end
    return size
end


