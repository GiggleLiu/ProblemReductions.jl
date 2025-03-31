using Test, ProblemReductions, Graphs

@testset "BMF_BicliqueCover" begin
    A = [1 0 ; 1 1]
    A = BitMatrix(A)
    bmf1 = BinaryMatrixFactorization(A, 2)
    bc1 = ProblemReductions.biclique_cover_from_matrix(Int.(A), 2)
    res = reduceto(BicliqueCover, bmf1)
    res1 = ReductionBMFToBicliqueCover(bc1,2)
    @test res == res1
    @test res.k == 2
    @test res.bicliquecover == bc1
    @test res.bicliquecover.part1 == [i for i in 1:size(A,1)]
    @test target_problem(res) == bc1
    @test extract_solution(res,[[1,1,1,0],[0,1,0,1]]) == ([true false ; true true], [true false ; false true])
end