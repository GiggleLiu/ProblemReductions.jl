"""
$TYPEDEF
The reduction result of a vertex matching to a set packing problem.

### Fields
- `SetPacking{WT<:AbstractVector{Int}}`: the set packing problem, where WT is the weights type.
- `edge_label` is the edge label of the matching problem.
"""
struct ReductionMatchingToSetPacking{ET1,ET2,T,WT<:AbstractVector{T}} <: AbstractReductionResult
    setpacking::SetPacking{ET1, T, WT}
    edge_label::Dict{ET2,Int}
end
Base.:(==)(a::ReductionMatchingToSetPacking, b::ReductionMatchingToSetPacking) = a.setpacking == b.setpacking && a.edge_label == b.edge_label

target_problem(res::ReductionMatchingToSetPacking) = res.setpacking

function reduceto(::Type{SetPacking}, s::Matching)
    sp,el = matching2setpacking(s.graph, s.weights)
    return ReductionMatchingToSetPacking(sp,el)
end

function matching2setpacking(g::SimpleGraph, weights)
    subsets = Vector{Vector{Int}}()
    edgs = edges(g)
    #indexing edges
    edge_label = Dict(zip(edgs, 1:ne(g)))
    # map edges to subset
    for edge in edges(g)
        push!(subsets,[edge.src, edge.dst])
    end
    return SetPacking(subsets, weights),edge_label
end

function extract_solution(res::ReductionMatchingToSetPacking, sol)
    return sol
end