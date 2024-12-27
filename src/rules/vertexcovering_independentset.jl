"""
$TYPEDEF

The reduction result of reducing an independent set problem to a vertex covering problem.

### Fields
- `vertexcovering::VertexCovering`: the vertex covering problem.    
"""
struct ReductionIndependentSetToVertexCovering{T, WT} <: AbstractReductionResult
    vertexcovering::VertexCovering{T, WT} 
end
Base.:(==)(a::ReductionIndependentSetToVertexCovering, b::ReductionIndependentSetToVertexCovering) = a.vertexcovering == b.vertexcovering

target_problem(res::ReductionIndependentSetToVertexCovering) = res.vertexcovering

function reduceto(::Type{<:VertexCovering}, is::IndependentSet{<:SimpleGraph})
    vc = VertexCovering(is.graph, is.weights)
    return ReductionIndependentSetToVertexCovering(vc)
end

# choose the complementary set of the solution
extract_solution(::ReductionIndependentSetToVertexCovering, sol) = map(x -> 1 .- x, sol)

