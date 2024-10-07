"""
$(TYPEDEF)
    SpinGlass(graph::AbstractGraph, weights::AbstractVector)
    SpinGlass(graph::SimpleGraph, J, h=zeros(nv(graph)))

The [spin-glass](https://giggleliu.github.io/ProblemReductions.jl/dev/models/SpinGlass/) problem.

Positional arguments
-------------------------------
* `graph` is a graph object.
* `weights` are associated with the edges.
"""
struct SpinGlass{GT<:AbstractGraph, T, WT<:AbstractVector{T}} <: ConstraintSatisfactionProblem{T}
    graph::GT
    weights::WT
    function SpinGlass(graph::AbstractGraph, weights::WT) where {T, WT<:AbstractVector{T}}
        @assert length(weights) == ne(graph)
        return new{typeof(graph), T, WT}(graph, weights)
    end
end
function SpinGlass(graph::SimpleGraph, J::Vector, h::Vector)
    @assert length(J) == ne(graph) "length of J must be equal to the number of edges $(ne(graph)), got: $(length(J))"
    @assert length(h) == nv(graph) "length of h must be equal to the number of vertices $(nv(graph)), got: $(length(h))"
    SpinGlass(HyperGraph(nv(graph), Vector{Int}[[[src(e), dst(e)] for e in edges(graph)]..., [[i] for i in 1:nv(graph)]...]), [J..., h...])
end
# Base.:(<symbol>) to overload the operators
Base.:(==)(a::SpinGlass, b::SpinGlass) = a.graph == b.graph && a.weights == b.weights
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
weights(gp::SpinGlass) = gp.weights
set_weights(c::SpinGlass, weights) = SpinGlass(c.graph, weights)
constraint_specs(sg::SpinGlass) = vedges(sg.graph)
local_energy(::Type{<:SpinGlass}, config) = prod(config)

# energy interface
function energy(problem::ConstraintSatisfactionProblem, config)
    @assert length(config) == num_variables(problem)
    eng = zero(eltype(weights(problem)))
    for spec in constraint_specs(problem)
        eng += local_energy(typeof(problem), config[spec]) * weights(problem)[spec]
    end
    return eng
end