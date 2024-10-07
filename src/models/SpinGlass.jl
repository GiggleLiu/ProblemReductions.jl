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
    J::WT
    h::WT
    function SpinGlass(graph::AbstractGraph, J::WT, h::WT) where {T, WT<:AbstractVector{T}}
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
    return vcat([LocalConstraint(e, :edge) for e in vedges(sg.graph)], [LocalConstraint([v], :vertex) for v in vertices(sg.graph)])
end
@nohard_constraints SpinGlass

function local_energy(::Type{<:SpinGlass}, spec::LocalConstraint, config)
    @assert length(config) == num_variables(spec)
    spec.specification == :edge ? prod(config) : config[]
end