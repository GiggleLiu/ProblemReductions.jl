"""
$(TYPEDEF)
    Coloring{K}(graph; weights=UnitWeight(nv(graph)))

The Vertex Coloring (Coloring) problem is defined on a simple graph. Given k kinds of colors, we need to determine whether we can color all vertices on the graph such that no two adjacent vertices share the same color.

Fields
-------------------------------
* `graph` is the problem graph.
* `weights` are associated with the edges of the `graph`, default to `UnitWeight(ne(graph))`.

Example
-------------------------------
To initialize a Coloring problem, we need to first define a graph and decide the number of colors.
```jldoctest
julia> using ProblemReductions, Graphs

julia> g = smallgraph(:petersen) # define a simple graph, petersen as example
{10, 15} undirected simple Int64 graph

julia> coloring = Coloring{3}(g)  # 3 colors
Coloring{3, Int64, UnitWeight}(SimpleGraph{Int64}(15, [[2, 5, 6], [1, 3, 7], [2, 4, 8], [3, 5, 9], [1, 4, 10], [1, 8, 9], [2, 9, 10], [3, 6, 10], [4, 6, 7], [5, 7, 8]]), [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1])

julia> variables(coloring)
10-element Vector{Int64}:
  1
  2
  3
  4
  5
  6
  7
  8
  9
 10

julia> flavors(coloring)
3-element Vector{Int64}:
 0
 1
 2

julia> is_vertex_coloring(coloring.graph,[1,2,3,1,3,2,1,2,3,1]) #random assignment
false
```
"""
struct Coloring{K, T, WT<:AbstractVector{T}} <: GraphProblem{T}
    graph::SimpleGraph{Int64}
    weights::WT
    function Coloring{K}(graph::SimpleGraph{Int64}, weights::AbstractVector{T}=UnitWeight(ne(graph))) where {K, T}
        @assert length(weights) == ne(graph) "length of weights must be equal to the number of edges $(ne(graph)), got: $(length(weights))"
        new{K, T, typeof(weights)}(graph, weights)
    end
end
Base.:(==)(a::Coloring, b::Coloring) = a.graph == b.graph && a.weights == b.weights
problem_size(c::Coloring) = (; num_vertices=nv(c.graph), num_edges=ne(c.graph))

# variables interface
variables(gp::Coloring{K}) where K = collect(1:nv(gp.graph))
flavors(::Type{<:Coloring{K}}) where K = collect(0:K-1) # colors
num_flavors(::Type{<:Coloring{K}}) where K = K # number of colors

# weights interface
weights(c::Coloring) = c.weights
set_weights(c::Coloring{K}, weights) where K = Coloring{K}(c.graph, weights)

# constraints interface
@nohard_constraints Coloring
function energy_terms(c::Coloring)
    # constraints on edges
    return [LocalConstraint(_vec(e), :coloring) for e in edges(c.graph)]
end

function local_energy(::Type{<:Coloring{K, T}}, spec::LocalConstraint, config) where {K, T}
    @assert length(config) == num_variables(spec)
    a, b = config
    return a == b ? one(T) : zero(T)
end

"""
    is_vertex_coloring(graph::SimpleGraph, config)

Returns true if the coloring specified by config is a valid one, i.e. does not violate the contraints of vertices of an edges having different colors.
"""
function is_vertex_coloring(graph::SimpleGraph, config)
    for e in edges(graph)
        config[e.src] == config[e.dst] && return false
    end
    return true
end

