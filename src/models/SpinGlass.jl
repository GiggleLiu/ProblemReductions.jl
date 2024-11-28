"""
$(TYPEDEF)
    SpinGlass(graph::AbstractGraph, weights::AbstractVector)
    SpinGlass(graph::SimpleGraph, J, h=zeros(nv(graph)))

Spin Glass is a type of disordered magnetic system that exhibits a glassy behavior. The Hamiltonian of the system on a simple graph ``G`` is given by
```math
H(G, \\sigma) = \\sum_{(i,j) \\in E(G)} J_{ij} \\sigma_i \\sigma_j + \\sum_{i \\in V(G)} h_i \\sigma_i
```
where ``J_{ij} \\in \\mathbb{R}`` is the coupling strength between spins ``i`` and ``j``, ``h_i \\in \\mathbb{R}`` is the external field on spin ``i``, and ``\\sigma_i`` is the spin variable that can take values in ``\\{-1, 1\\}`` for spin up and spin down, respectively.

This definition naturally extends to the case of a [`HyperGraph`](@ref):
```math
H(G, \\sigma) = \\sum_{e \\in E(G)} J_{e} \\prod_k\\sigma_k + \\sum_{i \\in V(G)} h_i \\sigma_i,
```
where ``J_e`` is the coupling strength associated with hyperedge ``e``, and the product is over all spins in the hyperedge.

Fields
-------------------------------
- `graph` is a graph object.
- `J` are the coupling strengths associated with the edges.
- `h` are the external fields associated with the vertices.

Example
-------------------------------
In the following example, we define a spin glass problem on a 4-vertex graph with random coupling strengths and external fields.
```jldoctest
julia> using ProblemReductions, ProblemReductions.Graphs

julia> graph = SimpleGraph(Graphs.SimpleEdge.([(1, 2), (1, 3), (3, 4), (2, 3)]))
{4, 4} undirected simple Int64 graph

julia> J = rand([1, -1], ne(graph))  # coupling strength
4-element Vector{Int64}:
  1
 -1
  1
 -1

julia> h = rand([1, -1], nv(graph))  # external field
4-element Vector{Int64}:
  1
 -1
  1
 -1

julia> spinglass = SpinGlass(graph, J, h)  # Define a spin glass problem
SpinGlass{SimpleGraph{Int64}, Int64, Vector{Int64}}(SimpleGraph{Int64}(4, [[2, 3], [1, 3], [1, 2, 4], [3]]), [1, -1, 1, -1], [1, -1, 1, -1])

julia> variables(spinglass)  # degrees of freedom
4-element Vector{Int64}:
 1
 2
 3
 4

julia> flavors(spinglass)  # flavors of the spins
2-element Vector{Int64}:
  1
 -1

julia> energy(spinglass, [-1, 1, 1, -1])  # energy of a configuration
2

julia> findbest(spinglass, BruteForce())  # solve the problem with brute force
2-element Vector{Vector{Int64}}:
 [-1, 1, -1, 1]
 [-1, 1, -1, -1]
```
"""
struct SpinGlass{GT<:AbstractGraph, T, WT<:AbstractVector{T}} <: ConstraintSatisfactionProblem{T}
    graph::GT
    J::WT
    h::Vector{T}
    function SpinGlass(graph::AbstractGraph, J::WT, h::Vector{T}) where {T, WT<:AbstractVector{T}}
        @assert length(J) == ne(graph)
        @assert length(h) == nv(graph)
        return new{typeof(graph), T, WT}(graph, J, h)
    end
end
Base.:(==)(a::SpinGlass, b::SpinGlass) = a.graph == b.graph && a.J == b.J && a.h == b.h
function spin_glass_from_matrix(M::AbstractMatrix, h::AbstractVector)
    g = SimpleGraph((!iszero).(M))
    J = [M[e.src, e.dst] for e in edges(g)]
    return SpinGlass(g, J, h)
end

# variables interface
variables(gp::SpinGlass) = collect(1:nv(gp.graph))
flavors(::Type{<:SpinGlass}) = [1, -1]
problem_size(c::SpinGlass) = (; num_vertices=nv(c.graph), num_edges=ne(c.graph))

# weights interface
weights(gp::SpinGlass) = vcat(gp.J, gp.h)
set_weights(c::SpinGlass, weights) = SpinGlass(c.graph, weights[1:ne(c.graph)], weights[ne(c.graph)+1:end])

# constraints interface
function energy_terms(sg::SpinGlass)
    return vcat([LocalConstraint(_vec(e), :edge) for e in edges(sg.graph)], [LocalConstraint([v], :vertex) for v in vertices(sg.graph)])
end
@nohard_constraints SpinGlass

function local_energy(::Type{<:SpinGlass}, spec::LocalConstraint, config)
    @assert length(config) == num_variables(spec)
    spec.specification == :edge ? prod(config) : first(config)
end
