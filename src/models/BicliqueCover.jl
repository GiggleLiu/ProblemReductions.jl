"""
$TYPEDEF
    BicliqueCover{K}(graph::SimpleGraph{Int64}, k::Int64,weights::WT)
The Biclique Cover problem is defined on a bipartite simple graph. Given a bipartite graph, the goal is to find a set of bicliques that cover all the edges in the graph. A biclique is a complete bipartite subgraph, denoted by G = (U ∪ V, E), where U and V are the two disjoint sets of vertices, and all pairs of vertices from U and V are connected by an edge, i.e., (u, v) ∈ E for all u ∈ U and v ∈ V. What's more, each bipartite simple graph could be identified by an adjacent matrix, where the rows and columns are the vertices in U and V, respectively. 
"""
struct BicliqueCover{Int64} <: ConstraintSatisfactionProblem{Int64}
    graph::SimpleGraph{Int64}
    k::Int64
    # when initialize the problem, ensure the first part of the vertices are in U, following the vertices of V
    function BicliqueCover(graph::SimpleGraph{Int64},k::Int64)
        @assert Graphs.is_bipartite(graph) "The graph is not bipartite"
        new{Int64}(graph,k)
    end
end

function biclique_cover_from_matrix(A::AbstractMatrix{Int64},k::Int64)
    graph = SimpleGraph(size(A,1)+size(A,2))
    for i in [i for i in 1:size(A,1)]
        for j in [j for j in 1:size(A,2)]
            if A[i,j] == 1
                add_edge!(graph,i,j+size(A,1))
            end
        end
    end
    return BicliqueCover(graph,k)
end
Base.:(==)(a::BicliqueCover, b::BicliqueCover) = a.graph == b.graph && a.k == b.k
problem_size(c::BicliqueCover) = (; num_vertices=nv(c.graph), num_edges=ne(c.graph), k=c.k)

# Variables Interface
# each vertex is assigned to a biclique, with k bicliques, variables(c::BicliqueCover) = fill(1,c.k * nv(c.graph)) 
num_variables(c::BicliqueCover) = nv(c.graph) * c.k
flavors(::Type{<:BicliqueCover}) = (0,1)
num_flavors(c::BicliqueCover) = 2

# constraints interface
function constraints(c::BicliqueCover)
    return [LocalConstraint(num_flavors(c), _vec(e), vec([_biclique_cover(config) for config in collect(Iterators.product([[0,1] for i in 1:length(_vec(e))]...))])) for e in edges(c.graph)]
end
function _biclique_cover(config)
    return all(!iszero, config)
end
# solution_size function for BicliqueCover, the solution size is the sum of the weights of the bicliques
function solution_size_multiple(c::BicliqueCover, configs)
    @assert all(length(config) <= c.k for config in configs)
    return map(configs) do config
        return SolutionSize(sum(i -> count(k -> k ==1, i),config), is_biclique_cover(c,config))
    end
end
solution_size(c::BicliqueCover, config) = first(solution_size_multiple(c, [config]))
energy_mode(::Type{<:BicliqueCover}) = SmallerSizeIsBetter()

function is_satisfied(c::BicliqueCover, config::Vector{Vector{Int64}}) 
    for cs in constraints(c)
        (src,dst) = cs.variables
        validity = any(config -> is_satisfied(cs,[config[src],config[dst]]), config)
        if !validity
            return false
        end
    end
    return true
end

# return true if the configuration is a biclique cover
function is_biclique_cover(bc::BicliqueCover, config)
    return is_satisfied(bc,config)
end

# return true if the configuration is a k-biclique cover
function is_k_biclique_cover(bc::BicliqueCover, config)
    return length(config) <= bc.k && is_biclique_cover(bc,config)
end



