struct HyperGraph <: Graphs.AbstractGraph{Int}
    n::Int
    edges::Vector{Vector{Int}}
    function HyperGraph(n::Int, cliques::Vector{Vector{Int}})
        @assert all(c->all(b->1<=b<=n, c), cliques) "vertex index out of bound 1-$n, got: $cliques"
        new(n, cliques)
    end
end
Graphs.nv(h::HyperGraph) = h.n
Graphs.vertices(h::HyperGraph) = 1:nv(h)
Graphs.ne(h::HyperGraph) = length(h.edges)
Graphs.edges(h::HyperGraph) = h.edges

struct UnitDiskGraph{D, T} <: Graphs.AbstractGraph{Int}
    locations::Vector{NTuple{D, T}}
    radius::T
end
Graphs.nv(g::UnitDiskGraph) = length(g.locations)
Graphs.vertices(g::UnitDiskGraph) = 1:nv(g)
Graphs.ne(g::UnitDiskGraph) = length(Graphs.edges(g))
function Graphs.edges(g::UnitDiskGraph)
    edges = Graphs.SimpleEdge{Int}[]
    for i in 1:nv(g), j in i+1:nv(g)
        if sum(abs2, g.locations[i] .- g.locations[j]) ≤ g.radius^2
            push!(edges, Graphs.SimpleEdge(i, j))
        end
    end
    return edges
end

struct GridGraph <: Graphs.AbstractGraph{Int}
    grid::BitMatrix
    radius::Float64
end
Graphs.nv(g::GridGraph) = sum(g.grid)
Graphs.vertices(g::GridGraph) = 1:nv(g)
Graphs.ne(g::GridGraph) = length(Graphs.edges(g))
function Graphs.edges(g::GridGraph)
    udg = UnitDiskGraph([Float64.(x.I) for x in findall(g.grid)], g.radius)
    return Graphs.edges(udg)
end

# not implemented
# struct PlanarGraph <: Graphs.AbstractGraph{Int}
# end