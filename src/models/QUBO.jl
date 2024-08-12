"""
$TYPEDEF

The quadratic unconstrained binary optimization.
```math
E = \\sum_{i,j} Q_{ij} x_i x_j
```
where `x_i \\in \\{0, 1\\}`.

### Arguments
- `matrix::AbstractMatrix`: the matrix Q of the QUBO problem.
"""
struct QUBO{T <: Real} <: AbstractProblem
    matrix::Matrix{T}
    function QUBO(matrix::Matrix{T}) where T
        @assert size(matrix, 1) == size(matrix, 2)
        return new{T}(matrix)
    end
end
Base.:(==)(a::QUBO, b::QUBO) = a.matrix == b.matrix

function QUBO(graph::SimpleGraph, edge_weights::Vector{T}, vertex_weights::Vector{T}) where T <: Real
    @assert length(edge_weights) == ne(graph) "length of edge_weights must be equal to the number of edges $(ne(graph)), got: $(length(edge_weights))"
    @assert length(vertex_weights) == nv(graph) "length of vertex_weights must be equal to the number of vertices $(nv(graph)), got: $(length(vertex_weights))"
    m = zeros(T, nv(graph), nv(graph))
    for (e, w) in zip(edges(graph), edge_weights)
        m[src(e), dst(e)] = m[dst(e), src(e)] = w / 2
    end
    m[1:nv(graph)+1:end] .= vertex_weights   # diagonal part is the bias
    return QUBO(m)
end

# variables interface
variables(c::QUBO) = collect(1:size(c.matrix, 1))
flavors(::Type{<:QUBO}) = [0, 1]

function evaluate(c::QUBO, config)
    @assert length(config) == num_variables(c)
    @assert all(x -> x in (0, 1), config)
    return transpose(config) * c.matrix * config
end