"""
$TYPEDEF

The reduction result from BinaryMatrixFactorization to BicliqueCover.

### Fields
- `bicliquecover`: The BicliqueCover problem.
- `k`: The number of bicliques.
"""
struct BMF_BicliqueCover{Int64} <: AbstractReductionResult
    bicliquecover::BicliqueCover{Int64}
    k::Int64
end
Base.:(==)(a::BMF_BicliqueCover, b::BMF_BicliqueCover) = a.bicliquecover == b.bicliquecover && a.k == b.k
target_problem(res::BMF_BicliqueCover) = res.bicliquecover

function reduceto(::Type{BicliqueCover}, bmf::BinaryMatrixFactorization)
    k = bmf.k
    A = Int.(bmf.A)
    return BMF_BicliqueCover(ProblemReductions.biclique_cover_from_matrix(A, k), k)
end

# Not implemented
function extract_solution(res::BMF_BicliqueCover, solution::Vector{Vector{Int64}})
    return solution
end

function extract_multiple_solutions(res::BMF_BicliqueCover, solution_set)
    return unique(extract_solution.(Ref(res), solution_set))
end