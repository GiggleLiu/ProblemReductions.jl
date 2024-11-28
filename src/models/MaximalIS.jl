"""
$TYPEDEF

Maximal independent set is a problem that very similar to the [`IndependentSet`](@ref) problem.
The difference is that the solution space of a maximal indepdent set problem does not include the independent sets that can be extended by adding one more vertex.

Fields
-------------------------------
- `graph` is the problem graph.
- `weights` are associated with the vertices of the `graph`.

Example
-------------------------------
In the following example, we define a maximal independent set problem on a graph with four vertices.
To define a `MaximalIS` problem, we need to specify the graph and possibily the weights associated with vertices.
The weights are set as unit by default in the current version and might be generalized to arbitrary positive weights in the following development.
```jldoctest
julia> using ProblemReductions, Graphs

julia> graph = SimpleGraph(Graphs.SimpleEdge.([(1, 2), (1, 3), (3, 4), (2, 3), (1, 4)]))
{4, 5} undirected simple Int64 graph

julia> problem = MaximalIS(graph)
MaximalIS{Int64, UnitWeight}(SimpleGraph{Int64}(5, [[2, 3, 4], [1, 3], [1, 2, 4], [1, 3]]), [1, 1, 1, 1])

julia> variables(problem)  # degrees of freedom
4-element Vector{Int64}:
 1
 2
 3
 4

julia> flavors(problem)
2-element Vector{Int64}:
 0
 1

julia> energy(problem, [0, 1, 0, 0])  # unlike the independent set, this configuration is not a valid solution
3037000500

julia> findbest(problem, BruteForce())
1-element Vector{Vector{Int64}}:
 [0, 1, 0, 1]
```
"""
struct MaximalIS{T, WT<:AbstractVector{T}} <: GraphProblem{T}
    graph::SimpleGraph
    weights::WT
    function MaximalIS(g::SimpleGraph, weights::AbstractVector{T}=UnitWeight(nv(g))) where {T}
        @assert weights isa UnitWeight || length(weights) == nv(g)
        new{T, typeof(weights)}(g, weights)
    end
end
Base.:(==)(a::MaximalIS, b::MaximalIS) = a.graph == b.graph && a.weights == b.weights

# variables interface
variables(gp::MaximalIS) = [1:nv(gp.graph)...]
num_variables(gp::MaximalIS) = nv(gp.graph)
flavors(::Type{<:MaximalIS}) = [0, 1]
problem_size(c::MaximalIS) = (; num_vertices=nv(c.graph), num_edges=ne(c.graph))

# weights interface
weights(c::MaximalIS) = c.weights
set_weights(c::MaximalIS, weights) = MaximalIS(c.graph, weights)

function hard_constraints(c::MaximalIS)
    return [LocalConstraint(vcat(v, neighbors(c.graph, v)), :maximal_independent) for v in vertices(c.graph)]
end
function is_satisfied(::Type{<:MaximalIS}, spec::LocalConstraint, config)
    @assert length(config) == num_variables(spec)
    nselect = count(!iszero, config)
    return !(nselect == 0 || (nselect > 1 && !iszero(first(config))))
end
# constraints interface
function energy_terms(c::MaximalIS)
    return [LocalConstraint([v], :vertex) for v in vertices(c.graph)]
end
function local_energy(::Type{<:MaximalIS{T}}, spec::LocalConstraint, config) where {T}
    @assert length(config) == num_variables(spec)
    return T(-first(config))
end

"""
    is_maximal_independent_set(g::SimpleGraph, config)

Return true if `config` (a vector of boolean numbers as the mask of vertices) is a maximal independent set of graph `g`.
"""
is_maximal_independent_set(g::SimpleGraph, config) = !any(e->config[e.src] == 1 && config[e.dst] == 1, edges(g)) && all(w->config[w] == 1 || any(v->!iszero(config[v]), neighbors(g, w)), Graphs.vertices(g))