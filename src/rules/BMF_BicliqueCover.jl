"""
$TYPEDEF

The reduction result from BinaryMatrixFactorization to BicliqueCover.

### Fields
- `bicliquecover`: The BicliqueCover problem.
"""
struct ReductionBMFToBicliqueCover{Int64} <: AbstractReductionResult
    bicliquecover::BicliqueCover{Int64}
end
Base.:(==)(a::ReductionBMFToBicliqueCover, b::ReductionBMFToBicliqueCover) = a.bicliquecover == b.bicliquecover
target_problem(res::ReductionBMFToBicliqueCover) = res.bicliquecover

function reduceto(::Type{<:BicliqueCover}, bmf::BinaryMatrixFactorization)
    bc = biclique_cover_from_matrix(Int.(bmf.A), bmf.k)
    return ReductionBMFToBicliqueCover(bc)
end

function extract_solution(res::ReductionBMFToBicliqueCover{Int64}, solution)
    return solution
end

"""
$TYPEDEF

The reduction result from BicliqueCover to BinaryMatrixFactorization.

### Fields
- `BMF`: The BinaryMatrixFactorization problem.
"""
struct ReductionBicliqueCoverToBMF <: AbstractReductionResult
    BMF::BinaryMatrixFactorization
end
Base.:(==)(a::ReductionBicliqueCoverToBMF, b::ReductionBicliqueCoverToBMF) = a.BMF == b.BMF
target_problem(res::ReductionBicliqueCoverToBMF) = res.BMF

function reduceto(::Type{<:BinaryMatrixFactorization}, biclique::BicliqueCover)
    len_part1 = length(biclique.part1)
    A = falses((len_part1,nv(biclique.graph)-len_part1))
    for e in edges(biclique.graph)
        if e.src in biclique.part1
            A[e.src, e.dst-len_part1] = true
        end
    end
    return ReductionBicliqueCoverToBMF(BinaryMatrixFactorization(A, biclique.k))
end

function extract_solution(res::ReductionBicliqueCoverToBMF, solution)
    return solution
end