"""
$TYPEDEF

The quadratic unconstrained binary optimization.

### Arguments
- `matrix::AbstractMatrix`: the matrix of the quadratic form.
- `bias::AbstractVector`: the bias vector.
"""
struct QUBO{T <: Real} <: AbstractProblem
    matrix::Matrix{T}
    bias::Vector{T}
    function QUBO(matrix::Matrix{T}, bias::Vector{T}) where T
        @assert size(matrix, 1) == size(matrix, 2) == length(bias)
        return new{T}(matrix, bias)
    end
end
Base.:(==)(a::QUBO, b::QUBO) = a.matrix == b.matrix && a.bias == b.bias

function QUBO(graph::SimpleGraph, edge_weights::Vector{T}, vertex_weights::Vector{T}) where T <: Real
    @assert length(edge_weights) == ne(graph) "length of edge_weights must be equal to the number of edges $(ne(graph)), got: $(length(edge_weights))"
    @assert length(vertex_weights) == nv(graph) "length of vertex_weights must be equal to the number of vertices $(nv(graph)), got: $(length(vertex_weights))"
    m = zeros(T, nv(graph), nv(graph))
    for (e, w) in zip(edges(graph), edge_weights)
        m[src(e), dst(e)] = m[dst(e), src(e)] = w / 2
    end
    return QUBO(m, vertex_weights)
end

# variables interface
variables(c::QUBO) = collect(1:size(c.matrix, 1))
flavors(::Type{<:QUBO}) = [0, 1]

function evaluate(c::QUBO, config)
    @assert length(config) == num_variables(c)
    @assert all(x -> x in (0, 1), config)
    return transpose(config) * c.matrix * config + sum(c.bias .* config)
end