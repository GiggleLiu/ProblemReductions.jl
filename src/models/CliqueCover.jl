"""
$TYPEDEF
    CliqueCover{K}(graph::SimpleGraph{Int64}, k::Int64)
    
A clique cover of a graph G is a set of cliques such that all vertices in G is coverd by the vertices union of these cliques. A K clique cover is to find whether we could use only k cliques to cover all the vertices in the graph.

"""
struct CliqueCover{Int64} <: ConstraintSatisfactionProblem{Int64}
    graph::SimpleGraph{Int64}
    k::Int64
    function CliqueCover(graph::SimpleGraph{Int64}, k::Int64)
        new{Int64}(graph, k)
    end
end
problem_size(c::CliqueCover) = (; num_vertices=nv(c.graph), num_edges=ne(c.graph), k=c.k)
num_variables(c::CliqueCover) = nv(c.graph) * c.k
num_flavors(c::CliqueCover) = 2

# constraints interface
function constraints(c::CliqueCover)
    return [LocalConstraint(num_flavors(c), v, [0,1]) for v in vertices(c.graph)]
end
function objectives(c::CliqueCover)
    return [LocalSolutionSize(num_flavors(c), [v], [0, 1]) for v in vertices(c.graph)]
end
energy_mode(::Type{<:CliqueCover}) = SmallerSizeIsBetter()

function is_clique_cover(configs::Vector{Vector{Int64}}, c::CliqueCover)
    # check if the number of cliques is equal to k
    if length(configs) != c.k
        print(1)
        return false
    end
    # check if they are all valid clique
    if any(config -> !is_clique(c, config), configs)
        print(2)
        return false
    end
    vertices_covered = reduce(vcat, [findall(x-> x==1,config) for config in configs])
    # check if the vertices are covered by the cliques
    if length(vertices_covered) != nv(c.graph)
        print(3)
        return false
    end
    return true
end
function is_clique(c::CliqueCover,config::Vector{Int64})
    vertices = findall(x -> x == 1, config)
    for (v1, v2) in collect(Iterators.product(vertices, vertices))
        # pass if the vertices are the same
        if v1 == v2
            continue
        end
        # check if the edge exists in the graph, if not, return false
        if !has_edge(c.graph, v1, v2)
            return false
        end
    end
    return true
end