"""
$TYPEDEF

The [Vertex matching](https://queracomputing.github.io/GenericTensorNetworks.jl/dev/generated/Matching/) problem.

Positional arguments
-------------------------------
- `graph` is the problem graph.
- `weights` are associated with the edges of the `graph`.
"""
struct Matching{T, WT<:AbstractVector{T}} <: ConstraintSatisfactionProblem{T}
    graph::SimpleGraph{Int}
    weights::WT
    function Matching(g::SimpleGraph, weights::AbstractVector{T}=UnitWeight(ne(g))) where {T}
        @assert length(weights) == ne(g)
        new{T, typeof(weights)}(g, weights)
    end
end
Base.:(==)(a::Matching, b::Matching) = a.graph == b.graph && a.weights == b.weights

flavors(::Type{<:Matching}) = (0, 1)
num_variables(gp::Matching) = ne(gp.graph)
problem_size(c::Matching) = (; num_vertices=nv(c.graph), num_edges=ne(c.graph))

# weights interface
weights(c::Matching) = c.weights
set_weights(c::Matching, weights) = Matching(c.graph, weights)

# constraints interface
function hard_constraints(c::Matching)
    # edges sharing a vertex cannot be both in the matching
    return [HardConstraint([i for (i, e) in enumerate(edges(c.graph)) if contains(e, v)], :noshare) for v in vertices(c.graph)]
end

function is_satisfied(::Type{<:Matching}, spec::HardConstraint, config)
    @assert length(config) == num_variables(spec)
    return count(isone, config) <= 1
end

function local_solution_spec(c::Matching)
    # as many edges as possible
    return [LocalSolutionSpec([e], :num_edges, w) for (w, e) in zip(weights(c), variables(c))]
end

"""
    solution_size(::Type{<:Matching{T}}, spec::LocalSolutionSpec{WT}, config) where {T, WT}

For [`Matching`](@ref), the solution size of a configuration is the number of edges in the matching.
"""
function solution_size(::Type{<:Matching{T}}, spec::LocalSolutionSpec{WT}, config) where {T, WT}
    @assert length(config) == num_variables(spec) == 1
    return WT(first(config)) * spec.weight
end
energy_mode(::Type{<:Matching}) = SmallerSizeIsBetter()

"""
    is_matching(graph::SimpleGraph, config)

Returns true if `config` is a valid matching on `graph`, and `false` if a vertex is double matched.
`config` is a vector of boolean variables, which has one to one correspondence with `edges(graph)`.
"""
function is_matching(g::SimpleGraph, config)
    @assert ne(g) == length(config)
    edges_mask = zeros(Bool, nv(g))
    for (e, c) in zip(edges(g), config)
        if !iszero(c)
            if edges_mask[e.src]
                return false
            end
            if edges_mask[e.dst]
                return false
            end
            edges_mask[e.src] = true
            edges_mask[e.dst] = true
        end
    end
    return true
end