using Test, ProblemReductions

@testset "BMF" begin
    # test 1
    A = trues(3, 3)
    k = 2
    bmf1 = BinaryMatrixFactorization(A, k)

    @test variables(bmf1) == [i for i in 1:12]
    @test num_variables(bmf1) == 12
    @test flavors(BinaryMatrixFactorization) == (0, 1)
    @test num_flavors(BinaryMatrixFactorization) == 2
    @test problem_size(bmf1) == (num_rows=3, num_cols=3, k=2)
    @test solution_size(bmf1, falses(3, 2), falses(2, 3)) == 9
    @test energy_mode(BinaryMatrixFactorization) == SmallerSizeIsBetter()
    @test is_binary_matrix_factorization(bmf1, falses(3, 2), falses(2, 3)) == false
    @test is_binary_matrix_factorization(bmf1,trues(3, 2), trues(2, 3)) == true
    bmf_a = BinaryMatrixFactorization(trues(3,3), 3)
    @test bmf1 != bmf_a
    bmf_b = BinaryMatrixFactorization(trues(3,3), 2)
    @test bmf1 == bmf_b

    # test 2
    A = trues(3, 3)
    k = 2
    bmf2 = BinaryMatrixFactorization(A, k)

    @test num_variables(bmf2) == 12
    @test flavors(BinaryMatrixFactorization) == (0, 1)
    @test problem_size(bmf2) == (num_rows=3, num_cols=3, k=2)
    @test solution_size(bmf2, falses(3, 2), falses(2, 3)) == 9
    @test energy_mode(BinaryMatrixFactorization) == SmallerSizeIsBetter()
    @test is_binary_matrix_factorization(bmf2, falses(3, 2), falses(2, 3)) == false
    @test is_binary_matrix_factorization(bmf2,trues(3, 2), trues(2, 3)) == true

    # test 3
    A = BitMatrix([1 0;1 1])
    bmf3 = BinaryMatrixFactorization(A, 2)
    @test read_solution(bmf3, BitMatrix([1 0 ; 1 1]), BitMatrix([1 0 ; 0 1])) == [[1,1,1,0],[0,1,0,1]]
end