using ProblemReductions, Test, LinearAlgebra

@testset "qubo" begin
    # construct several QUBO problems
    matrix01 = [[1., 0, 0], [0, 1., 0], [0, 0, 1.]]
    Q01 = hcat(matrix01...)
    QUBO01 = QUBO(Q01)
    QUBO02 = QUBO(I(3))
    @test QUBO01 == QUBO02

    # QUBO from Graph
    graph = SimpleGraph(3)
    add_edge!(graph, 1, 1)
    add_edge!(graph, 2, 2)
    add_edge!(graph, 3, 3)
    QUBO03 = QUBO_from_SimpleGraph(graph, [1., 1., 1.])
    @test QUBO01 == QUBO03
    
    # variables
    @test variables(QUBO01) == [1, 2, 3]
    @test num_variables(QUBO01) == 3
    @test flavors(QUBO01) == [0, 1]
    @test num_flavors(QUBO01) == 2

    # evaluate
    @test evaluate(QUBO01, [0, 0, 0]) == 0
    @test evaluate(QUBO01, [1, 1, 0]) == 2
    @test findbest(QUBO01, BruteForce()) == [ [0, 0, 0] ]
end