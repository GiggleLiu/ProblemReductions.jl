struct HyperEdge{T} <: Graphs.AbstractEdge{T}
    vertices::Vector{T}
end
Base.:(==)(a::HyperEdge, b::HyperEdge) = same_edge(a, b)

"""
$TYPEDEF

A hypergraph is a generalization of a graph in which an edge can connect any number of vertices.

### Fields
- `n::Int`: the number of vertices
- `edges::Vector{Vector{Int}}`: a vector of vectors of integers, where each vector represents a hyperedge connecting the vertices with the corresponding indices.
"""
struct HyperGraph <: Graphs.AbstractGraph{Int}
    n::Int
    edges::Vector{HyperEdge{Int}}
    function HyperGraph(n::Int, cliques::Vector{HyperEdge{Int}})
        @assert all(c->all(b->1<=b<=n, c.vertices), cliques) "vertex index out of bound 1-$n, got: $cliques"
        new(n, cliques)
    end
end
HyperGraph(n::Int, cliques::Vector{Vector{Int}}) = HyperGraph(n, [HyperEdge(c) for c in cliques])
Base.:(==)(a::HyperGraph, b::HyperGraph) = a.n == b.n && a.edges == b.edges
Graphs.nv(h::HyperGraph) = h.n
Graphs.vertices(h::HyperGraph) = 1:nv(h)
Graphs.ne(h::HyperGraph) = length(h.edges)
Graphs.edges(h::HyperGraph) = h.edges
contains(e::HyperEdge, v::Int) = v ∈ e.vertices
contains(e::Graphs.SimpleEdge, v::Int) = src(e) == v || dst(e) == v
num_vertices(e::HyperEdge) = length(e.vertices)
num_vertices(e::Graphs.SimpleEdge) = 2
same_edge(a::Graphs.SimpleEdge, b::Graphs.SimpleEdge) = (a.src == b.src && a.dst == b.dst) || (a.src == b.dst && a.dst == b.src)
same_edge(a::HyperEdge, b::HyperEdge) = sort(a.vertices) == sort(b.vertices)
iterable(e::Graphs.SimpleEdge) = (src(e), dst(e))
iterable(e::HyperEdge) = e.vertices
Graphs.has_edge(h::HyperGraph, e::HyperEdge) = any(x->same_edge(x, e), edges(h))

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
Base.:(==)(a::UnitDiskGraph, b::UnitDiskGraph) = a.locations == b.locations && a.radius == b.radius
Graphs.nv(g::UnitDiskGraph) = length(g.locations)
Graphs.vertices(g::UnitDiskGraph) = 1:nv(g)
Graphs.ne(g::UnitDiskGraph) = length(all_edges(g))

Graphs.edges(g::UnitDiskGraph) = Graphs.SimpleGraphs.SimpleEdgeIter(g)

function Graphs.has_edge(g::UnitDiskGraph, s, d)
    verts = vertices(g)
    (s in verts && d in verts) || return false  # edge out of bounds
    return sum(abs2, g.locations[s] .- g.locations[d]) ≤ g.radius^2
end

function Graphs.has_edge(g::UnitDiskGraph, e::Graphs.SimpleGraphEdge{T}) where {T}
    s, d = T.(Tuple(e))
    return has_edge(g, s, d)
end

function all_edges(g::UnitDiskGraph)
    edges = Graphs.SimpleEdge{Int}[]
    for i in 1:nv(g), j in i+1:nv(g)
        if sum(abs2, g.locations[i] .- g.locations[j]) ≤ g.radius^2
            push!(edges, Graphs.SimpleEdge(i, j))
        end
    end
    return edges
end

Base.eltype(::Type{Graphs.SimpleGraphs.SimpleEdgeIter{UnitDiskGraph{D,T}}}) where {D,T} = Graphs.SimpleGraphEdge{Int}

@inline function Base.iterate(
    eit::Graphs.SimpleGraphs.SimpleEdgeIter{G}, state=(1, 2)
) where {G<:UnitDiskGraph}
    g = eit.g
    n = nv(g)
    i, j = state

    @inbounds while i <= n
        if j > n
            i += 1
            j = i + 1
            continue
        end

        # return the next edge if it exists
        if sum(abs2, g.locations[i] .- g.locations[j]) ≤ g.radius^2
            e = Graphs.SimpleEdge(i, j)
            state = (i, j + 1)
            return e, state
        end
        
        j += 1
    end

    return nothing
end

"""
$TYPEDEF

A grid graph is a graph in which the vertices are arranged in a grid and two vertices are connected by an edge if and only if they are adjacent in the grid.
If the input is a boolean matrix, vertices are arranged in the column major order.

### Fields
- `grid::BitMatrix`: a matrix of booleans, where `true` indicates the presence of an edge.
- `radius::Float64`: the radius of the unit disk
"""
struct GridGraph <: Graphs.AbstractGraph{Int}
    size::Tuple{Int, Int}
    coordinates::Vector{Tuple{Int, Int}}
    radius::Float64
end
function GridGraph(matrix::AbstractMatrix{Bool}, radius)
    return GridGraph(size(matrix), vec(getfield.(findall(matrix), :I)), Float64(radius))
end
Base.:(==)(a::GridGraph, b::GridGraph) = a.grid == b.grid && a.radius == b.radius
Graphs.nv(g::GridGraph) = length(g.coordinates)
Graphs.vertices(g::GridGraph) = 1:nv(g)
Graphs.ne(g::GridGraph) = length(Graphs.edges(g))
function Graphs.edges(g::GridGraph)
    udg = UnitDiskGraph(map(x->Float64.(x), g.coordinates), g.radius)
    return Graphs.edges(udg)
end
function Graphs.neighbors(g::GridGraph, i::Int)
    [j for j in 1:nv(g) if i != j && distance(g.coordinates[i], g.coordinates[j]) <= g.radius]
end
distance(n1, n2) = sqrt(sum(abs2, n1 .- n2))
function Graphs.induced_subgraph(g::GridGraph, vlist::AbstractVector{<:Integer})
    return GridGraph(g.size, g.coordinates[vlist], g.radius), vlist
end

# not implemented
# struct PlanarGraph <: Graphs.AbstractGraph{Int}
# end

##### Extra interfaces #####
_vec(e::Graphs.SimpleEdge) = [src(e), dst(e)]
_vec(e::HyperEdge) = e.vertices

# TODO: make it more efficient
# add an edge to a graph with a given weight
function _add_edge_weight!(g::SimpleGraph, edg::Graphs.SimpleEdge{Int}, J, weight)
    has_edge(g, edg) && for (i, e) in enumerate(edges(g))
        if same_edge(e, edg)
            J[i] += weight
            return
        end
    end
    add_edge!(g, edg)
    # fix the edge index
    for (i, e) in enumerate(edges(g))
        if same_edge(edg, e)
            insert!(J, i, weight)
        end
    end
end
function _add_edge_weight!(g::HyperGraph, c::HyperEdge{Int}, J, weight)
    if has_edge(g, c)  # if the edge already exists, add the weight to the existing edge
        J[findfirst(x->same_edge(x, c), edges(g))] += weight
        return
    end
    push!(g.edges, c)
    push!(J, weight)
end
