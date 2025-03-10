"""
$(TYPEDEF)
    IndependentSet(graph::AbstractGraph, weights::AbstractVector=UnitWeight(nv(graph))) -> IndependentSet

Independent Set is a subset of vertices in a undirected graph such that all the vertices in the set are not connected by edges (or called not adjacent).
The maximum IndependentSet problem is to find the independent set with maximum number of vertices, which is a NP-complete problem.
Let ``G=(V, E)`` be a graph, and ``w_v`` be the weight of vertex ``v``.
The energy based model of the independent set problem is:
```math
H(G, \\mathbf{n}) = - \\sum_{v \\in V} w_v n_v + \\sum_{(u, v) \\in E} n_u n_v
```
where ``n_v`` is the number of vertices in the independent set, i.e. ``n_v = 1`` if ``v`` is in the independent set, and ``n_v = 0`` otherwise.
The larger the size of the independent set, the lower the energy.

Fields
-------------------------------
- `graph::AbstractGraph`: The problem graph.
- `weights::AbstractVector`: Weights associated with the vertices of the `graph`. Defaults to `UnitWeight(nv(graph))`.

Example
-------------------------------
In the following example, we define an independent set problem on a graph with four vertices.
To define an `IndependentSet` problem, we need to specify the graph and possibily the weights associated with vertices.
The weights are set as unit by default in the current version and might be generalized to arbitrary positive weights.
```jldoctest
julia> using ProblemReductions, Graphs

julia> graph = SimpleGraph(Graphs.SimpleEdge.([(1, 2), (1, 3), (3, 4), (2, 3)]))
{4, 4} undirected simple Int64 graph

julia> IS = IndependentSet(graph)
IndependentSet{SimpleGraph{Int64}, Int64, UnitWeight}(SimpleGraph{Int64}(4, [[2, 3], [1, 3], [1, 2, 4], [3]]), [1, 1, 1, 1])

julia> num_variables(IS)  # degrees of freedom
4

julia> flavors(IS)  # flavors of the vertices
(0, 1)

julia> solution_size(IS, [1, 0, 0, 1]) # Positive sample: -(size) of an independent set
SolutionSize{Int64}(2, true)

julia> solution_size(IS, [0, 1, 1, 0]) # Negative sample: 0
SolutionSize{Int64}(2, false)

julia> findbest(IS, BruteForce())  # solve the problem with brute force
2-element Vector{Vector{Int64}}:
 [1, 0, 0, 1]
 [0, 1, 0, 1]
```
"""
struct IndependentSet{GT<:AbstractGraph, T, WT<:AbstractVector{T}} <: ConstraintSatisfactionProblem{T}
    graph::GT
    weights::WT
    function IndependentSet(graph::AbstractGraph, weights::AbstractVector{T}=UnitWeight(nv(graph))) where {T}
        return new{typeof(graph), T, typeof(weights)}(graph, weights)
    end
end
Base.:(==)(a::IndependentSet, b::IndependentSet) = a.graph == b.graph && a.weights == b.weights

# Variables Interface
num_variables(gp::IndependentSet) = nv(gp.graph)
num_flavors(::Type{<:IndependentSet}) = 2
problem_size(c::IndependentSet) = (; num_vertices=nv(c.graph), num_edges=ne(c.graph))

# weights interface
weights(c::IndependentSet) = c.weights
set_weights(c::IndependentSet, weights) = IndependentSet(c.graph, weights)

# constraints interface
function constraints(c::IndependentSet)
    return [LocalConstraint(num_flavors(c), _vec(e), [_independence_constraint(config) for config in combinations(num_flavors(c), length(_vec(e)))]) for e in edges(c.graph)]
end
function _independence_constraint(config)
    return count(!iszero, config) <= 1
end

function objectives(c::IndependentSet)
    return [LocalSolutionSize(num_flavors(c), [v], [zero(w), w]) for (w, v) in zip(weights(c), vertices(c.graph))]
end
energy_mode(::Type{<:IndependentSet}) = LargerSizeIsBetter()

"""
    is_independent_set(g::SimpleGraph, config)

Return true if `config` (a vector of boolean numbers as the mask of vertices) is an independent set of graph `g`.
"""
is_independent_set(g::AbstractGraph, config) = !any(e->count(x->isone(config[x]), _vec(e)) > 1, edges(g))