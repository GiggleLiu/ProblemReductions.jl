"""
$(TYPEDEF)
    IndependentSet(graph::AbstractGraph, weights::AbstractVector=UnitWeight(nv(graph))) -> IndependentSet

Independent Set is a subset of vertices in a undirected graph such that all the vertices in the set are not connected by edges (or called not adjacent).
The maximum IndependentSet problem is to find the independent set with maximum number of vertices, which is a NP-complete problem.

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

julia> variables(IS)  # degrees of freedom
4-element Vector{Int64}:
 1
 2
 3
 4

julia> flavors(IS)  # flavors of the vertices
2-element Vector{Int64}:
 0
 1

julia> energy(IS, [1, 0, 0, 1]) # Positive sample: -(size) of an independent set
-2

julia> energy(IS, [0, 1, 1, 0]) # Negative sample: 0
3037000500

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
variables(gp::IndependentSet) = [1:nv(gp.graph)...]
flavors(::Type{<:IndependentSet}) = [0, 1]
problem_size(c::IndependentSet) = (; num_vertices=nv(c.graph), num_edges=ne(c.graph))

# weights interface
weights(c::IndependentSet) = c.weights
set_weights(c::IndependentSet, weights) = IndependentSet(c.graph, weights)

# constraints interface
function hard_constraints(c::IndependentSet)
    return [LocalConstraint(_vec(e), nothing) for e in edges(c.graph)]
end
function is_satisfied(::Type{<:IndependentSet}, spec::LocalConstraint, config)
    @assert length(config) == num_variables(spec)
    return count(!iszero, config) <= 1
end

function energy_terms(c::IndependentSet)
    return [LocalConstraint([i], nothing) for i in 1:nv(c.graph)]
end

function local_energy(::Type{<:IndependentSet{GT, T}}, spec::LocalConstraint, config) where {GT, T}
    @assert length(config) == num_variables(spec) == 1
    return T(-first(config))
end