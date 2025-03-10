"""
$(TYPEDEF)
    Coloring{K}(graph; weights=UnitWeight(nv(graph)), use_constraints::Bool=false)

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
1:10

julia> flavors(coloring)
(0, 1, 2)

julia> is_vertex_coloring(coloring.graph,[1,2,3,1,3,2,1,2,3,1]) #random assignment
false
```
"""
struct Coloring{K, T, WT<:AbstractVector{T}, OBJ} <: ConstraintSatisfactionProblem{T}
    graph::SimpleGraph{Int64}
    weights::WT
    function Coloring{K, OBJ}(graph::SimpleGraph{Int64}, weights::AbstractVector{T}=UnitWeight(ne(graph))) where {K, T, OBJ}
        @assert length(weights) == ne(graph) "length of weights must be equal to the number of edges $(ne(graph)), got: $(length(weights))"
        @assert OBJ == EXTREMA || weights isa UnitWeight "Only unit weights are supported for SAT objective type."
        new{K, T, typeof(weights), OBJ}(graph, weights)
    end
end
function Coloring{K}(graph::SimpleGraph{Int64}, weights::AbstractVector=UnitWeight(ne(graph)); use_constraints::Bool=false) where K
    OBJ = use_constraints ? SAT : EXTREMA
    return Coloring{K, OBJ}(graph, weights)
end
Base.:(==)(a::Coloring, b::Coloring) = a.graph == b.graph && a.weights == b.weights
problem_size(c::Coloring) = (; num_vertices=nv(c.graph), num_edges=ne(c.graph))

# variables interface
num_variables(gp::Coloring{K}) where K = nv(gp.graph)
num_flavors(::Type{<:Coloring{K}}) where K = K

# weights interface
weights(c::Coloring) = c.weights
set_weights(c::Coloring{K, T, WT, EXTREMA}, weights::AbstractVector) where {K, T, WT} = Coloring{K, EXTREMA}(c.graph, weights)

# constraints interface (EXTREMA)
@noconstraints Coloring{K, T, WT, EXTREMA} where {K, T, WT}
function objectives(c::Coloring{K, T, WT, EXTREMA}) where {K, T, WT}
    # constraints on edges
    return [LocalSolutionSize(num_flavors(c), _vec(e), [w * _coloring_constraint(config) for config in combinations(num_flavors(c), 2)]) for (w, e) in zip(weights(c), edges(c.graph))]
end
function _coloring_constraint(config) # return true if the coloring is valid
    a, b = config
    return a == b ? false : true
end

# constraints interface (SAT)
function constraints(c::Coloring{K, T, WT, SAT}) where {K, T, WT}
    # constraints on edges
    return [LocalConstraint(num_flavors(c), _vec(e), [_coloring_constraint(config) for config in combinations(num_flavors(c), 2)]) for e in edges(c.graph)]
end
objectives(::Coloring{K, T, WT, SAT}) where {K, T, WT} = LocalSolutionSize{T}[]

energy_mode(::Type{<:Coloring}) = LargerSizeIsBetter()

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

