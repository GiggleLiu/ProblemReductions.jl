using Test, ProblemReductions

@testset "BMF" begin
    # test 1
    A = fill(1, 3, 3)
    k = 2
    bmf = BinaryMatrixFactorization(A, k)

    @test variables(bmf) == 3 * 2 + 3 * 2
    @test flavors(BinaryMatrixFactorization) == (0, 1)
    @test problem_size(bmf) == (num_rows=3, num_cols=3, k=2)
    @test solution_size(bmf, fill(0, 3, 2), fill(0, 2, 3)) == 9
    @test energy_mode(BinaryMatrixFactorization) == SmallerSizeIsBetter()
    @test is_binary_matrix_factorization(bmf, fill(0, 3, 2), fill(0, 2, 3)) == false
    @test is_binary_matrix_factorization(bmf,fill(1, 3, 2), fill(1, 2, 3)) == true

    # test 2
    A = fill(true, 3, 3)
    k = 2
    bmf = BinaryMatrixFactorization(A, k)

    @test variables(bmf) == 3 * 2 + 3 * 2
    @test flavors(BinaryMatrixFactorization) == (0, 1)
    @test problem_size(bmf) == (num_rows=3, num_cols=3, k=2)
    @test solution_size(bmf, fill(0, 3, 2), fill(0, 2, 3)) == 9
    @test energy_mode(BinaryMatrixFactorization) == SmallerSizeIsBetter()
    @test is_binary_matrix_factorization(bmf, fill(0, 3, 2), fill(0, 2, 3)) == false
    @test is_binary_matrix_factorization(bmf,fill(1, 3, 2), fill(1, 2, 3)) == true
end