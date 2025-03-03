"""
$TYPEDEF
    BicliqueCover{K}(graph::SimpleGraph{Int64}, k::Int64,weights::WT)
The Biclique Cover problem is defined on a bipartite simple graph. Given a bipartite graph, the goal is to find a set of bicliques that cover all the edges in the graph. A biclique is a complete bipartite subgraph, denoted by G = (U ∪ V, E), where U and V are the two disjoint sets of vertices, and all pairs of vertices from U and V are connected by an edge, i.e., (u, v) ∈ E for all u ∈ U and v ∈ V. What's more, each bipartite simple graph could be identified by an adjacent matrix, where the rows and columns are the vertices in U and V, respectively. 
"""
struct BicliqueCover{WT,T} <: ConstraintSatisfactionProblem{T}
    graph::SimpleGraph{Int64}
    k::Int64
    weights::WT
    # when initialize the problem, ensure the first part of the vertices are in U, following the vertices of V
    function BicliqueCover(graph::SimpleGraph{Int64},k::Int64,weights::AbstractVector{T}=UnitWeight(nv(graph))) where T
        new{typeof(weights),T}(graph,k,weights)
    end
end

function biclique_cover_from_matrix(A::AbstractMatrix{Int64},k::Int64,weights::AbstractVector{T}=UnitWeight(ne(graph))) where T
    graph = SimpleGraph{Int64}(size(A,1)+size(A,2))
    for (i,j) in (1:size(A,1), 1:size(A,2))
        if A[i,j]
            add_edge!(graph, i,j+size(A,1))
        end
    end
    new{typeof(weights),T}(graph,k,weights)
end
problem_size(c::BicliqueCover) = (; num_vertices=nv(c.graph), num_edges=ne(c.graph), k=c.k)

# Variables Interface
# each vertex is assigned to a biclique, with k bicliques, variables(c::BicliqueCover) = fill(1,c.k * nv(c.graph)) 
num_variables(c::BicliqueCover) = nv(c.graph) * c.k
flavors(::Type{<:BicliqueCover}) = (0,1)

# Weights Interface
weights(bc::BicliqueCover) = bc.weights
set_weights(bc::BicliqueCover, weights) = BicliqueCover(bc.graph, bc.k, weights)

# Constraint Interface
function hard_constraints(bc::BicliqueCover)
    return [HardConstraint(_vec(e), :cover) for e in edges(bc.graph)]
end

function is_satisfied(::Type{<:BicliqueCover}, spec::HardConstraint, config)
    @assert length(config) == num_variables(spec)
    return any(!iszero, config)
end

function local_solution_spec(c::BicliqueCover)
    return [LocalSolutionSpec([v], :vertex, w) for (w, v) in zip(weights(c), vertices(c.graph))]
end

"""
    solution_size(c::BicliqueCover, spec::LocalSolutionSpec, config)
The solution size of a [`BicliqueCover`](@ref) model is the sum of the weights of the selected bicliques.
"""
function solution_size(c::BicliqueCover, spec::LocalSolutionSpec,config::AbstractVector{Int64})
    @assert length(config) == nv(c.graph) * c.k "config length mismatch"
    bicliques = [Set(findall(x->x==1,config[(i-1)*c.k+1:i*c.k])) for i in 1:nv(c.graph)]
    return sum(WT(length(b))*spec.weight for b in bicliques)
end

energy_mode(::Type{<:BicliqueCover}) = SmallerSizeIsBetter()

# not yet implemented
function is_biclique_cover(graph::SimpleGraph, config)
    return true
end

