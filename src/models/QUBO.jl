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
struct QUBO{T <: Real} <: ConstraintSatisfactionProblem{T}
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
problem_size(c::QUBO) = (; num_variables=size(c.matrix, 1))

# constraints interface
constraints(c::QUBO) = [(i, j)=>qubo_local_energy.(configuration_space(QUBO, 2), i == j ? c.matrix[i, i] : c.matrix[i, j] + c.matrix[j, i]) for i in variables(c), j in variables(c) if i < j && c.matrix[i, j] != 0 && c.matrix[j, i] != 0]
qubo_local_energy(config, weight) = config[1] * config[2] * weight

function energy(c::QUBO, config)
    @assert length(config) == num_variables(c)
    @assert all(x -> x in (0, 1), config)
    return transpose(config) * c.matrix * config
end