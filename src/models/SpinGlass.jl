"""
$(TYPEDEF)
    SpinGlass(graph::AbstractGraph, J, h=zeros(nv(graph)))

The [spin-glass](https://queracomputing.github.io/GenericTensorNetworks.jl/dev/generated/SpinGlass/) problem.

Positional arguments
-------------------------------
* `graph` is a graph object.
* `weights` are associated with the edges.
"""
struct SpinGlass{GT<:AbstractGraph, T} <: AbstractProblem
    graph::GT
    weights::Vector{T}
    function SpinGlass(graph::AbstractGraph, weights::Vector{T}) where T
        @assert length(weights) == ne(graph)
        return new{typeof(graph), T}(graph, weights)
    end
end
function SpinGlass(graph::SimpleGraph, J::Vector, h::Vector)
    @assert length(J) == ne(graph) "length of J must be equal to the number of edges $(ne(graph)), got: $(length(J))"
    @assert length(h) == nv(graph) "length of h must be equal to the number of vertices $(nv(graph)), got: $(length(h))"
    SpinGlass(HyperGraph(nv(graph), Vector{Int}[[[src(e), dst(e)] for e in edges(graph)]..., [[i] for i in 1:nv(graph)]...]), [J..., h...])
end
Base.:(==)(a::SpinGlass, b::SpinGlass) = a.graph == b.graph && a.weights == b.weights
function spin_glass_from_matrix(M::AbstractMatrix, h::AbstractVector)
    g = SimpleGraph((!iszero).(M))
    J = [M[e.src, e.dst] for e in edges(g)]
    return SpinGlass(g, J, h)
end

# variables interface
variables(gp::SpinGlass) = collect(1:nv(gp.graph))
flavors(::Type{<:SpinGlass}) = [0, 1]

# weights interface
get_weights(gp::SpinGlass, i::Int) = [-gp.weights[i], gp.weights[i]]
chweights(c::SpinGlass, weights) = SpinGlass(c.graph, weights)
terms(gp::SpinGlass) = edges(gp.graph)

function evaluate(sg::SpinGlass, config)
    @assert length(config) == num_variables(sg)
    spinglass_energy(terms(sg), config; weights=sg.weights)
end

"""
    spinglass_energy(g::SimpleGraph, config; J, h)
    spinglass_energy(cliques::AbstractVector{Vector{Int}}, config; weights)

Compute the spin glass state energy for the vertex configuration `config`.
In the configuration, the spin ↑ is mapped to configuration 0, while spin ↓ is mapped to configuration 1.
Let ``G=(V,E)`` be the input graph, the hamiltonian is
```math
H = \\sum_{ij \\in E} J_{ij} s_i s_j + \\sum_{i \\in V} h_i s_i,
```
where ``s_i \\in \\{-1, 1\\}`` stands for spin ↓ and spin ↑.

In the hypergraph case, the hamiltonian is
```math
H = \\sum_{c \\in C} w_c \\prod_{i \\in c} s_i,
```
where ``C`` is the set of cliques, and ``w_c`` is the weight of the clique ``c``.
"""
function spinglass_energy(cliques::AbstractVector{Vector{Int}}, config; weights)::Real
    size = zero(eltype(weights))
    @assert all(x->x == 0 || x == 1, config)
    s = 1 .- 2 .* Int.(config)  # 0 -> spin 1, 1 -> spin -1
    for (i, spins) in enumerate(cliques)
        size += prod(s[spins]) * weights[i]
    end
    return size
end
function spinglass_energy(g::SimpleGraph, config; J, h)
    eng = zero(promote_type(eltype(J), eltype(h)))
    # NOTE: cast to Int to avoid using unsigned :nt
    s = 1 .- 2 .* Int.(config)  # 0 -> spin 1, 1 -> spin -1
    # coupling terms
    for (i, e) in enumerate(edges(g))
        eng += (s[e.src] * s[e.dst]) * J[i]
    end
    # onsite terms
    for (i, v) in enumerate(vertices(g))
        eng += s[v] * h[i]
    end
    return eng
end