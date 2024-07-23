using Test, ProblemReductions, Graphs

@testset "independentset" begin
    # construct a graph
    g01 = SimpleGraph(4)
    add_edge!(g01, 1, 2) 
    add_edge!(g01, 1, 3)
    add_edge!(g01, 3, 4)
    add_edge!(g01, 2, 3)

    g02 = SimpleGraph(4)
    add_edge!(g02, 1, 3) 
    add_edge!(g02, 1, 2)
    add_edge!(g02, 2, 3)
    add_edge!(g02, 3, 4)

    # construct a IndependentSet problem
    IS_01 = IndependentSet(g01)
    IS_02 = IndependentSet(g02)
    @test IS_01 == IS_02

    # variables
    @test variables(IS_01) == [1, 2, 3, 4]
    @test num_variables(IS_01) == 4
    @test flavors(IndependentSet) == [0, 1]

    # evaluate
    # Positive example
    @test evaluate(IS_01, [1, 0, 0, 1]) == 0
    @test evaluate(IS_01, [0, 1, 0, 1]) == 0
    @test evaluate(IS_01, [0, 1, 1, 0]) == 1
end