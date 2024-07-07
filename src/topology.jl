"""
$TYPEDEF

A hypergraph is a generalization of a graph in which an edge can connect any number of vertices.

### Fields
- `n::Int`: the number of vertices
- `edges::Vector{Vector{Int}}`: a vector of vectors of integers, where each vector represents a hyperedge connecting the vertices with the corresponding indices.
"""
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

"""
$TYPEDEF

A unit disk graph is a graph in which the vertices are points in a plane and two vertices are connected by an edge if and only if the Euclidean distance between them is at most a given radius.

### Fields
- `n::Int`: the number of vertices
- `locations::Vector{NTuple{D, T}}`: the locations of the vertices
- `radius::T`: the radius of the unit disk
"""
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

"""
$TYPEDEF

A grid graph is a graph in which the vertices are arranged in a grid and two vertices are connected by an edge if and only if they are adjacent in the grid.

### Fields
- `grid::BitMatrix`: a matrix of booleans, where `true` indicates the presence of an edge.
- `radius::Float64`: the radius of the unit disk
"""
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