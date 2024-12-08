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

julia> num_variables(IS)  # degrees of freedom
4

julia> flavors(IS)  # flavors of the vertices
(0, 1)

julia> solution_size(IS, [1, 0, 0, 1]) # Positive sample: -(size) of an independent set
-2

julia> solution_size(IS, [0, 1, 1, 0]) # Negative sample: 0
0

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
flavors(::Type{<:IndependentSet}) = (0, 1)
problem_size(c::IndependentSet) = (; num_vertices=nv(c.graph), num_edges=ne(c.graph))

# weights interface
weights(c::IndependentSet) = c.weights
set_weights(c::IndependentSet, weights) = IndependentSet(c.graph, weights)

# constraints interface
function hard_constraints(c::IndependentSet)
    return [HardConstraint(_vec(e), :independence) for e in edges(c.graph)]
end
function is_satisfied(::Type{<:IndependentSet}, spec::HardConstraint, config)
    @assert length(config) == num_variables(spec)
    return count(!iszero, config) <= 1
end

function local_solution_spec(c::IndependentSet)
    return [LocalSolutionSpec([i], :num_vertex, w) for (w, i) in zip(weights(c), 1:nv(c.graph))]
end

"""
    solution_size(::Type{<:IndependentSet{GT, T}}, spec::LocalSolutionSpec{WT}, config) where {GT, T, WT}

For [`IndependentSet`](@ref), the solution size of a configuration is the weight of vertices in the independent set.
"""
function solution_size(::Type{<:IndependentSet{GT, T}}, spec::LocalSolutionSpec{WT}, config) where {GT, T, WT}
    @assert length(config) == num_variables(spec) == 1
    return WT(first(config)) * spec.weight
end
energy_mode(::Type{<:IndependentSet}) = LargerSizeIsBetter()