"""
$TYPEDEF

The reduction result from BinaryMatrixFactorization to BicliqueCover.

### Fields
- `bicliquecover`: The BicliqueCover problem.
- `k`: The number of bicliques.
"""
struct ReductionBMFToBicliqueCover{Int64} <: AbstractReductionResult
    bicliquecover::BicliqueCover{Int64}
    k::Int64
end
Base.:(==)(a::ReductionBMFToBicliqueCover, b::ReductionBMFToBicliqueCover) = a.bicliquecover == b.bicliquecover && a.k == b.k
target_problem(res::ReductionBMFToBicliqueCover) = res.bicliquecover

function reduceto(::Type{BicliqueCover}, bmf::BinaryMatrixFactorization)
    k = bmf.k
    A = Int.(bmf.A)
    return ReductionBMFToBicliqueCover(ProblemReductions.biclique_cover_from_matrix(A, k), k)
end

function extract_solution(res::ReductionBMFToBicliqueCover{Int64}, solution::Vector{Vector{Int64}})
    len_part1 = length(res.bicliquecover.part1)
    len_part2 = nv(res.bicliquecover.graph) - len_part1
    B = falses((len_part1,res.k))
    C = falses((res.k,len_part1))
    # each iteration, we update the a-th column of B and the a-th row of C
    for a in range(1,res.k)
        for i in range(1,len_part1)
            if solution[a][i] == 1
                B[i,a] = true
            end
        end
        for j in range(1,len_part2)
            if solution[a][j+len_part1] == 1
                C[a,j] = true
            end
        end
    end
    return (B,C)
end

function extract_multiple_solutions(res::ReductionBMFToBicliqueCover{Int64}, solution_set::Vector{Vector{Vector{Int64}}})
    return unique(extract_solution.(Ref(res), solution_set))
end