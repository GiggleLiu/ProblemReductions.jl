"""
$TYPEDEF

A Vertex Cover is a subset of vertices in a graph, such that for an arbitrary edge, the subset includes at least one of the endpoints.
The minimum vertex covering problem is to find the minimum vertex cover for a given graph, which is a NP-complete problem.

Fields
-------------------------------
- `graph` is a graph object.
- `weights` are associated with the vertices of the `graph`, default to `UnitWeight(nv(graph))`.

Example
-------------------------------
In the following example, we define a vertex covering problem on a graph with four vertices.
To define a `VertexCovering` problem, we need to specify the graph and the weights associated with edges. The weights are by default set as unit.
```jldoctest
julia> using ProblemReductions, Graphs

julia> graph = SimpleGraph(Graphs.SimpleEdge.([(1,2), (1,3), (3,4), (2,3), (1,4)]))
{4, 5} undirected simple Int64 graph

julia> weights = [1, 3, 1, 4]
4-element Vector{Int64}:
 1
 3
 1
 4

julia> VC= VertexCovering(graph, weights)
VertexCovering{Int64, Vector{Int64}}(SimpleGraph{Int64}(5, [[2, 3, 4], [1, 3], [1, 2, 4], [1, 3]]), [1, 3, 1, 4])

julia> num_variables(VC)  # degrees of freedom
4

julia> solution_size(VC, [1, 0, 0, 1]) # Negative sample
SolutionSize{Int64}(5, false)

julia> solution_size(VC, [0, 1, 1, 0]) # Positive sample
SolutionSize{Int64}(4, false)

julia> findbest(VC, BruteForce())  # solve the problem with brute force
1-element Vector{Vector{Int64}}:
 [1, 0, 1, 0]

julia> VC02 = set_weights(VC, [1, 2, 3, 4])  # set the weights of the subsets
VertexCovering{Int64, Vector{Int64}}(SimpleGraph{Int64}(5, [[2, 3, 4], [1, 3], [1, 2, 4], [1, 3]]), [1, 2, 3, 4])
```
"""
struct VertexCovering{T, WT<:AbstractVector{T}} <: ConstraintSatisfactionProblem{T}
    graph::SimpleGraph{Int64}
    weights::WT
    function VertexCovering(graph::SimpleGraph{Int64}, weights::AbstractVector{T}=UnitWeight(nv(graph))) where {T}
        @assert length(weights) == nv(graph) "length of weights must be equal to the number of vertices $(nv(graph)), got: $(length(weights))"
        new{T, typeof(weights)}(graph, weights)
    end
end
Base.:(==)(a::VertexCovering, b::VertexCovering) = a.graph == b.graph && a.weights == b.weights

# variables interface
num_variables(gp::VertexCovering) = nv(gp.graph)
num_flavors(::Type{<:VertexCovering}) = 2 # whether the vertex is selected (1) or not (0)
problem_size(c::VertexCovering) = (; num_vertices=nv(c.graph), num_edges=ne(c.graph))

#weights interface 
weights(c::VertexCovering) = c.weights
set_weights(c::VertexCovering, weights) = VertexCovering(c.graph, weights)

# constraints interface
function hard_constraints(c::VertexCovering)
    return [HardConstraint(num_flavors(c), _vec(e), [_vertex_covering(config) for config in combinations(num_flavors(c), length(_vec(e)))]) for e in edges(c.graph)]
end
function _vertex_covering(config)
    return any(!iszero, config)
end
function local_solution_spec(c::VertexCovering)
    return [LocalSolutionSpec(num_flavors(c), [v], [zero(w), w]) for (w, v) in zip(weights(c), vertices(c.graph))]
end
energy_mode(::Type{<:VertexCovering}) = SmallerSizeIsBetter()

"""
    is_vertex_covering(graph::SimpleGraph, config)
return true if the vertex configuration `config` is a vertex covering of the graph.
Our judgement is based on the fact that for each edge, at least one of its vertices is selected.
"""
function is_vertex_covering(graph::SimpleGraph, config)
    @assert length(config) == nv(graph)
    for e in edges(graph)
        config[e.src] == 0 && config[e.dst] == 0 && return false
    end
    return true
end