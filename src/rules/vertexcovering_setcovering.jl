"""
$TYPEDEF

The reduction result of a vertex covering to a set covering problem.

### Fields
- `setcovering::SetCovering{ET,WT}`: the set covering problem, where ET is the sets type and WT is the weights type.
- `edgelabel`: map each edge to a number in order to identify the edge (otherwise the vector would be cluttering)
"""
struct ReductionVertexCoveringToSetCovering{ET, WT<:AbstractVector} <: AbstractReductionResult
    setcovering::SetCovering{ET, WT}
    edgelabel::Dict{Vector{Int}, Int}
end
Base.:(==)(a::ReductionVertexCoveringToSetCovering, b::ReductionVertexCoveringToSetCovering) = a.setcovering == b.setcovering && a.edgelabel == b.edgelabel

target_problem(res::ReductionVertexCoveringToSetCovering) = res.setcovering

function reduceto(::Type{<:SetCovering}, vc::VertexCovering)
    sc, edgelabel = vertexcovering2setcovering(vc) #vertexcovering2setcovering
    return ReductionVertexCoveringToSetCovering(sc, edgelabel)
end

function vertexcovering2setcovering(vc::VertexCovering)
    edgs = vedges(vc.graph)
    return SetCovering(map(j->findall(e->j ∈ e, edgs), vertices(vc.graph)), vc.weights), Dict(zip(edgs, 1:ne(vc.graph)))
end

function extract_solution(res::ReductionVertexCoveringToSetCovering, sol)
    out = zeros(eltype(sol), num_variables(res.setcovering))
    for (k, v) in enumerate(variables(res.setcovering))
        out[v] = sol[k]
    end
    return out
end