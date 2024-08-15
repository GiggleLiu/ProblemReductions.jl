"""
$TYPEDEF

The [Vertex matching](https://queracomputing.github.io/GenericTensorNetworks.jl/dev/generated/Matching/) problem.

Positional arguments
-------------------------------
* `graph` is the problem graph.
* `weights` are associated with the edges of the `graph`.
"""
struct Matching{WT<:Union{UnitWeight,Vector}} <: AbstractProblem
    graph::SimpleGraph{Int}
    weights::WT
    function Matching(g::SimpleGraph, weights::Union{UnitWeight, Vector}=UnitWeight(ne(g)))
        @assert weights isa UnitWeight || length(weights) == ne(g)
        new{typeof(weights)}(g, weights)
    end
end

flavors(::Type{<:Matching}) = [0, 1]
variables(gp::Matching) = collect(1:ne(gp.graph))
num_variables(gp::Matching) = ne(gp.graph)

# weights interface
parameters(c::Matching) = c.weights
set_parametes(c::Matching, weights) = Matching(c.graph, weights)

"""
    evaluate(c::Matching, config)
    Return Inf if the configuration is not a matching, otherwise return the sum of the weights of the edges in the matching.
"""
function evaluate(c::Matching, config)
    @assert length(config) == ne(c.graph)
    if !is_matching(c.graph, config)
        return Inf
    end
    return sum(i -> config[i]*c.weights[i], 1:ne(c.graph))
end

"""
    is_matching(graph::SimpleGraph, config)

Returns true if `config` is a valid matching on `graph`, and `false` if a vertex is double matched.
`config` is a vector of boolean variables, which has one to one correspondence with `edges(graph)`.
"""
function is_matching(g::SimpleGraph, config)
    @assert ne(g) == length(config)
    edges_mask = zeros(Bool, nv(g))
    for (e, c) in zip(vedges(g), config)
        if !iszero(c)
            if edges_mask[e[1]]
                return false
            end
            if edges_mask[e[2]]
                return false
            end
            edges_mask[e[1]] = true
            edges_mask[e[2]] = true
        end
    end
    return true
end