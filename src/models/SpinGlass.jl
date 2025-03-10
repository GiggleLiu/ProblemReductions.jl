"""
$(TYPEDEF)
    SpinGlass(graph::AbstractGraph, weights::AbstractVector)
    SpinGlass(graph::SimpleGraph, J, h=zeros(nv(graph)))

Spin Glass is a type of disordered magnetic system that exhibits a glassy behavior. The Hamiltonian of the system on a simple graph ``G=(V, E)`` is given by
```math
H(G, \\sigma) = \\sum_{(i,j) \\in E} J_{ij} \\sigma_i \\sigma_j + \\sum_{i \\in V} h_i \\sigma_i
```
where ``J_{ij} \\in \\mathbb{R}`` is the coupling strength between spins ``i`` and ``j``, ``h_i \\in \\mathbb{R}`` is the external field on spin ``i``, and ``\\sigma_i \\in \\{-1, 1\\}`` is the spin variable.
The configuration of a solution is specified by a binary variable in (0, 1), where 0 and 1 are mapped to spins -1 and 1, respectively.

This definition naturally extends to the case of a [`HyperGraph`](@ref):
```math
H(G, \\sigma) = \\sum_{e \\in E} J_{e} \\prod_k\\sigma_k + \\sum_{i \\in V} h_i \\sigma_i,
```
where ``J_e`` is the coupling strength associated with hyperedge ``e``, and the product is over all spins in the hyperedge.

Fields
-------------------------------
- `graph` is a graph object.
- `J` are the coupling strengths associated with the edges.
- `h` are the external fields associated with the vertices.

Example
-------------------------------
In the following example, we define a spin glass problem on a 4-vertex graph with given coupling strengths on edges and external fields on vertices.
```jldoctest
julia> using ProblemReductions, ProblemReductions.Graphs

julia> graph = SimpleGraph(Graphs.SimpleEdge.([(1, 2), (1, 3), (3, 4), (2, 3)]))
{4, 4} undirected simple Int64 graph

julia> J = [1, -1, 1, -1]  # coupling strength
4-element Vector{Int64}:
  1
 -1
  1
 -1

julia> h = [1, -1, -1, 1]  # external field
4-element Vector{Int64}:
  1
 -1
 -1
  1

julia> spinglass = SpinGlass(graph, J, h)  # Define a spin glass problem
SpinGlass{SimpleGraph{Int64}, Int64, Vector{Int64}}(SimpleGraph{Int64}(4, [[2, 3], [1, 3], [1, 2, 4], [3]]), [1, -1, 1, -1], [1, -1, -1, 1])

julia> num_variables(spinglass)  # degrees of freedom
4

julia> flavors(spinglass)  # flavors of the spins, 0 for up (+1), 1 for down (-1)
(0, 1)

julia> solution_size(spinglass, [1, 0, 0, 1])  # size of a configuration
SolutionSize{Int64}(-2, true)

julia> findbest(spinglass, BruteForce())  # solve the problem with brute force
1-element Vector{Vector{Int64}}:
 [1, 0, 1, 1]
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
num_variables(gp::SpinGlass) = nv(gp.graph)
num_flavors(::Type{<:SpinGlass}) = 2
flavor_names(::Type{<:SpinGlass}) = ['↑', '↓']
problem_size(c::SpinGlass) = (; num_vertices=nv(c.graph), num_edges=ne(c.graph))

# weights interface
weights(gp::SpinGlass) = vcat(gp.J, gp.h)
set_weights(c::SpinGlass, weights) = SpinGlass(c.graph, weights[1:ne(c.graph)], weights[ne(c.graph)+1:end])

# constraints interface
function objectives(sg::SpinGlass)
    return vcat([LocalSolutionSize(num_flavors(sg), _vec(e), [_spin_glass_energy(w, config) for config in combinations(num_flavors(sg), length(_vec(e)))]) for (w, e) in zip(sg.J, edges(sg.graph))], [LocalSolutionSize(num_flavors(sg), [v], [w, -w]) for (w, v) in zip(sg.h, vertices(sg.graph))])
end
function _spin_glass_energy(w::T, config) where T
    return w * T(prod(c -> 1 - 2 * c, config))
end

@noconstraints SpinGlass
energy_mode(::Type{<:SpinGlass}) = SmallerSizeIsBetter()
