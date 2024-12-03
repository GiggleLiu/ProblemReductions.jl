"""
$(TYPEDEF)
    DominatingSet(graph::AbstractGraph, weights::AbstractVector=UnitWeight(ne(graph))) -> DominatingSet

Dominaing Set is a subset of vertices in a undirected graph such that all the vertices in the set are either in the dominating set or in its first-order neighborhood.
The DominatingSet problem is to find the dominating set with minimum number of vertices.

Fields
-------------------------------
- `graph` is the problem graph.
- `weights::AbstractVector`: Weights associated with the vertices of the `graph`. Defaults to `UnitWeight(nv(graph))`.

Example
-------------------------------
In the following example, we define a dominating set problem on a path graph with five vertices.
To define a `DominatingSet` problem, we need to specify the graph and possibily the weights associated with vertices.
The weights are set as unit by default in the current version and might be generalized to arbitrary positive weights in the following development.
```jldoctest
julia> using ProblemReductions, Graphs

julia> graph = path_graph(5)
{5, 4} undirected simple Int64 graph

julia> DS = DominatingSet(graph)
DominatingSet{SimpleGraph{Int64}, Int64, UnitWeight}(SimpleGraph{Int64}(4, [[2], [1, 3], [2, 4], [3, 5], [4]]), [1, 1, 1, 1, 1])

julia> variables(DS)  # degrees of freedom
5-element Vector{Int64}:
 1
 2
 3
 4
 5

julia> flavors(DS)  # flavors of the vertices
2-element Vector{Int64}:
 0
 1

julia> energy(DS, [0, 1, 0, 1, 0]) # Positive sample: (size) of a dominating set
2

julia> energy(DS, [0, 1, 1, 0, 0]) # Negative sample: number of vertices
3037000502

julia> findbest(DS, BruteForce())  # solve the problem with brute force
3-element Vector{Vector{Int64}}:
 [1, 0, 0, 1, 0]
 [0, 1, 0, 1, 0]
 [0, 1, 0, 0, 1]
```
"""
struct DominatingSet{GT<:AbstractGraph, T, WT<:AbstractVector{T}} <: ConstraintSatisfactionProblem{T}
    graph::GT
    weights::WT
    function DominatingSet(graph::AbstractGraph, weights::AbstractVector{T}=UnitWeight(nv(graph))) where {T}
        return new{typeof(graph), T, typeof(weights)}(graph, weights)
    end
end
Base.:(==)(a::DominatingSet, b::DominatingSet) = ( a.graph == b.graph )

# Variables Interface
variables(gp::DominatingSet) = [1:nv(gp.graph)...]
flavors(::Type{<:DominatingSet}) = [0, 1]
problem_size(c::DominatingSet) = (; num_vertices=nv(c.graph), num_edges=ne(c.graph))

# Weights Interface
weights(c::DominatingSet) = c.weights
set_weights(c::DominatingSet, weights) = DominatingSet(c.graph, weights)

# Constraints Interface
@nohard_constraints DominatingSet
function energy_terms(c::DominatingSet)
    # constraints on vertex and its neighbours
    return [LocalConstraint(vcat(v, neighbors(c.graph, v)), :dominating) for v in vertices(c.graph)]
end

function local_energy(::Type{<:DominatingSet{GT, T}}, spec::LocalConstraint, config) where {GT, T}
    @assert length(config) == num_variables(spec)
    nselect = count(isone, config)
    return nselect < 1 ? energy_max(T) : T(first(config))
end
