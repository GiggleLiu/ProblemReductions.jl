"""
$TYPEDEF

Max Cut problem is defined on weighted graphs. The goal is to find a partition of the vertices into two sets such that the sum of the weights of the edges between the two sets is maximized.

Positional arguments
-------------------------------
- `graph` is the problem graph.
- `weights` are associated with the edges of the `graph`. We have ensure that the `weights` are in the same order as the edges in `edges(graph)`.

Example
-------------------------------
In the following example, we solve a Max Cut problem on a complete graph with 3 vertices and edge weights `[1,2,3]`.
```jldoctest
julia> using ProblemReductions, Graphs

julia> g = complete_graph(3)
{3, 3} undirected simple Int64 graph

julia> maxcut = MaxCut(g,[1,2,3]) # specify the weights of the edges
MaxCut{Int64, Vector{Int64}}(SimpleGraph{Int64}(3, [[2, 3], [1, 3], [1, 2]]), [1, 2, 3])

julia> mc = set_weights(maxcut, [2,1,3]) # set the weights and get a new instance
MaxCut{Int64, Vector{Int64}}(SimpleGraph{Int64}(3, [[2, 3], [1, 3], [1, 2]]), [2, 1, 3])


julia> num_variables(maxcut) # return the number of vertices
3

julia> flavors(maxcut) # return the flavors of the vertices
2-element Vector{Int64}:
 0
 1

julia> energy(maxcut, [0,1,0]) # return the energy of the configuration
-4

julia> findbest(maxcut, BruteForce()) # find the best configuration
2-element Vector{Vector{Int64}}:
 [1, 1, 0]
 [0, 0, 1]
```
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
num_variables(gp::MaxCut) = nv(gp.graph)
flavors(::Type{<:MaxCut}) = [0, 1] #choose it or not
problem_size(c::MaxCut) = (; num_vertices=nv(c.graph), num_edges=ne(c.graph))
                            
# weights interface
weights(c::MaxCut) = c.weights
set_weights(c::MaxCut, weights) = MaxCut(c.graph, weights)

# constraints interface
function energy_terms(c::MaxCut)
    return [LocalConstraint(_vec(e), :cut) for e in edges(c.graph)]
end
function local_energy(::Type{<:MaxCut{T}}, spec::LocalConstraint, config) where {T}
    @assert length(config) == num_variables(spec)
    a, b = config
    return (a != b) ? -one(T) : zero(T)
end
@nohard_constraints MaxCut

function cut_size(terms, config; weights=UnitWeight(length(terms)))
    size = zero(promote_type(eltype(weights)))
    for (i,j) in zip(terms, weights)
        size += (config[i[1]] != config[i[2]]) * j  # terms are the edges,and terms[1],terms[2] are the two vertices of the edge.
    end
    return size
end


