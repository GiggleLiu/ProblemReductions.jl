"""
$TYPEDEF
    BicliqueCover{K}(graph::SimpleGraph{Int}, k::Int)
The Biclique Cover problem is defined on a bipartite simple graph. Given a bipartite graph, the goal is to find a set of bicliques that cover all the edges in the graph. A biclique is a complete bipartite subgraph, denoted by G = (U ∪ V, E), where U and V are the two disjoint sets of vertices, and all pairs of vertices from U and V are connected by an edge, i.e., (u, v) ∈ E for all u ∈ U and v ∈ V. What's more, each bipartite simple graph could be identified by an adjacent matrix, where the rows and columns are the vertices in U and V, respectively. 
"""
struct BicliqueCover{K} <: ConstraintSatisfactionProblem{K}
    graph::SimpleGraph{Int64}
    function BicliqueCover{K}(graph::SimpleGraph{Int64}) where K
        new{K}(graph)
    end
end

function biclique_cover_from_matrix{K}(A::AbstractMatrix{Int64}) where K
    graph = SimpleGraph{Int64}(size(A,1)+size(A,2))
    for (i,j) in (1:size(A,1), 1:size(A,2))
        if A[i,j]
            add_edge!(graph, i,j)
        end
    end
    new{K}(graph)
end

get_k(::Type{<:BicliqueCover{K}}) where K = K
variables(c::BicliqueCover) = 1:nv(c.graph)