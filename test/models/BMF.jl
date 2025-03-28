using Test, ProblemReductions

@testset "BMF" begin
    # test 1
    A = trues(3, 3)
    k = 2
    bmf = BinaryMatrixFactorization(A, k)

    @test variables(bmf) == [i for i in 1:12]
    @test num_variables(bmf) == 12
    @test flavors(BinaryMatrixFactorization) == (0, 1)
    @test num_flavors(BinaryMatrixFactorization) == 2
    @test problem_size(bmf) == (num_rows=3, num_cols=3, k=2)
    @test solution_size(bmf, falses(3, 2), falses(2, 3)) == 9
    @test energy_mode(BinaryMatrixFactorization) == SmallerSizeIsBetter()
    @test is_binary_matrix_factorization(bmf, falses(3, 2), falses(2, 3)) == false
    @test is_binary_matrix_factorization(bmf,trues(3, 2), trues(2, 3)) == true
    bmf1 = BinaryMatrixFactorization(trues(3,3), 3)
    @test bmf != bmf1
    bmf2 = BinaryMatrixFactorization(trues(3,3), 2)
    @test bmf == bmf2

    # test 2
    A = trues(3, 3)
    k = 2
    bmf = BinaryMatrixFactorization(A, k)

    @test num_variables(bmf) == 12
    @test flavors(BinaryMatrixFactorization) == (0, 1)
    @test problem_size(bmf) == (num_rows=3, num_cols=3, k=2)
    @test solution_size(bmf, falses(3, 2), falses(2, 3)) == 9
    @test energy_mode(BinaryMatrixFactorization) == SmallerSizeIsBetter()
    @test is_binary_matrix_factorization(bmf, falses(3, 2), falses(2, 3)) == false
    @test is_binary_matrix_factorization(bmf,trues(3, 2), trues(2, 3)) == true
end