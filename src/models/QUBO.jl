"""
QUBO(Q::AbstractMatrix)

The [QUBO] problem (Quadratic unconstrained binary optimization).

Positional arguments
---------------------
* `Q` is a real square matrix.
"""
struct QUBO{QT<:AbstractMatrix} <: AbstractProblem
    matrix::QT
    function QUBO(matrix::AbstractMatrix)
        @assert size(matrix, 1) == size(matrix, 2)
        return new{typeof(matrix)}(matrix)
    end
end
Base.:(==)(a::QUBO, b::QUBO) = a.matrix == b.matrix
function QUBO_from_SimpleGraph(graph::SimpleGraph, weights::Vector)
    @assert length(weights) == ne(graph) "length of weights must be equal to the number of edges $(ne(graph)), got: $(length(weights))"
    Q = zeros(Float64, nv(graph), nv(graph))
    edge_idx = 0
    for e in edges(graph)
        edge_idx += 1
        i = src(e)
        j = dst(e)
        Q[i, j] = weights[edge_idx]
        Q[j, i] = weights[edge_idx]
    end
    return QUBO(Q)
end

# variables interface
variables(c::QUBO) = collect(1:size(c.matrix, 1))
flavors(::Type{<:QUBO}) = [0, 1]

"""
    evaluate(c::QUBO, config)

Compute the quadratic form b^T*Q*b.
"""
function evaluate(c::QUBO, config)
    @assert length(config) == num_variables(c)
    @assert all(x -> x in (0, 1), config)
    return transpose(config) * c.matrix * config
end