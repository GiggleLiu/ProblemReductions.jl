"""
$TYPEDEF

The quadratic unconstrained binary optimization.
```math
E = \\sum_{i,j} Q_{ij} x_i x_j
```
where ``x_i \\in \\{0, 1\\}``.

### Arguments
- `matrix::AbstractMatrix`: the matrix Q of the QUBO problem.

```jldoctest
julia> using ProblemReductions, Graphs
       # Matrix method

julia> Q = [1. 0 0; 0 1 0; 0 0 1]
3×3 Matrix{Float64}:
 1.0  0.0  0.0
 0.0  1.0  0.0
 0.0  0.0  1.0

julia> QUBO01 = QUBO(Q)
       # Graph method
QUBO{Float64}([1.0 0.0 0.0; 0.0 1.0 0.0; 0.0 0.0 1.0])

julia> graph = SimpleGraph(3)
{3, 0} undirected simple Int64 graph

julia> QUBO02 = QUBO(graph, Float64[], [1., 1., 1.])
QUBO{Float64}([1.0 0.0 0.0; 0.0 1.0 0.0; 0.0 0.0 1.0])

julia> num_variables(QUBO01)  # degrees of freedom
3

julia> flavors(QUBO01)  # flavors of the vertices
(0, 1)

julia> solution_size(QUBO01, [0, 1, 0])
SolutionSize{Float64}(1.0, true)

julia> solution_size(QUBO02, [0, 1, 0])
SolutionSize{Float64}(1.0, true)

julia> findbest(QUBO01, BruteForce())  # solve the problem with brute force
1-element Vector{Vector{Int64}}:
 [0, 0, 0]

julia> findbest(QUBO02, BruteForce())
1-element Vector{Vector{Int64}}:
 [0, 0, 0]
```
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
num_variables(c::QUBO) = size(c.matrix, 1)
num_flavors(::Type{<:QUBO}) = 2
problem_size(c::QUBO) = (; num_variables=size(c.matrix, 1))

function weights(c::QUBO)
    return vcat(
        [c.matrix[i, j] + c.matrix[j, i] for i in variables(c), j in variables(c) if i < j && (c.matrix[i, j] != 0 || c.matrix[j, i] != 0)],
        [c.matrix[i, i] for i in variables(c) if c.matrix[i, i] != 0]
    )
end

# constraints interface
function local_solution_spec(c::QUBO{T}) where T
    return vcat(
        [LocalSolutionSpec(num_flavors(c), [i, j], [zero(T), zero(T), zero(T), c.matrix[i, j] + c.matrix[j, i]]) for i in variables(c), j in variables(c) if i < j && (c.matrix[i, j] != 0 || c.matrix[j, i] != 0)],
        [LocalSolutionSpec(num_flavors(c), [i], [zero(T), c.matrix[i, i]]) for i in variables(c) if c.matrix[i, i] != 0]
    )
end
@nohard_constraints QUBO

"""
    solution_size(::Type{<:QUBO}, spec::LocalSolutionSpec, config)

For [`QUBO`](@ref), the solution size of a configuration is the energy of the QUBO problem.
"""
function solution_size(::Type{<:QUBO}, spec::LocalSolutionSpec, config)
    @assert length(config) == num_variables(spec)
    if spec.specification == :offdiagonal
        a, b = config
        return a * b * spec.weight
    else
        return first(config) * spec.weight
    end
end
energy_mode(::Type{<:QUBO}) = SmallerSizeIsBetter()
