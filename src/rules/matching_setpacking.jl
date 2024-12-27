"""
$TYPEDEF
The reduction result of a vertex matching to a set packing problem.

### Fields
- `SetPacking{WT<:AbstractVector{Int}}`: the target set packing problem
"""
struct ReductionMatchingToSetPacking{ET,T,WT<:AbstractVector{T}} <: AbstractReductionResult
    setpacking::SetPacking{ET, T, WT}
end
Base.:(==)(a::ReductionMatchingToSetPacking, b::ReductionMatchingToSetPacking) = a.setpacking == b.setpacking

target_problem(res::ReductionMatchingToSetPacking) = res.setpacking

function reduceto(::Type{SetPacking}, s::Matching)
    sp = matching2setpacking(s.graph, s.weights)
    return ReductionMatchingToSetPacking(sp)
end

function matching2setpacking(g::SimpleGraph, weights)
    subsets = Vector{Vector{Int}}()
    # map edges to subset
    for edge in edges(g)
        push!(subsets,[edge.src, edge.dst])
    end
    return SetPacking(subsets, weights)
end

function extract_solution(res::ReductionMatchingToSetPacking, sol)
    return sol
end