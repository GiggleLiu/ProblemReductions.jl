using Test, ProblemReductions

@testset "BMF" begin
    # construction function
    A = fill(1, 3, 3)
    k = 2
    bmf = BinaryMatrixFactorization(A, k)

    @test variables(bmf) == 3 * 2 + 3 * 2
    @test flavors(BinaryMatrixFactorization) == (0, 1)
    @test problem_size(bmf) == (num_rows=3, num_cols=3, k=2)
    solution_size(bmf, fill(0, 3, 2), fill(0, 2, 3))
end