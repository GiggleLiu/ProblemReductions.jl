using ProblemReductions, Test, LinearAlgebra

@testset "qubo" begin
    # construct several QUBO problems
    matrix01 = [[1, 0, 0], [0, 1, 0], [0, 0, 1]]
    Q01 = hcat(matrix01...)
    QUBO01 = QUBO(Q01)
    QUBO02 = QUBO(I(3))
    @test QUBO01 == QUBO02
    

    # variables
    @test variables(QUBO01) == [1, 2, 3]
    @test num_variables(QUBO01) == 4
    @test flavors(QUBO01) == [0, 1]
    @test num_flavors(QUBO01) == 2

    # evaluate
    @test evaluate(QUBO01, [0, 0, 0]) == 0
    @test evaluate(QUBO01, [1, 1, 0]) == 2
    @test findbest(QUBO01, BruteForce()) == [ [0, 0, 0] ]
end