using Test, ProblemReductions, Graphs

@testset "maxcut" begin
    # construct a graph
    g = SimpleGraph(4)
    add_edge!(g, 1, 2) 
    add_edge!(g, 1, 3)
    add_edge!(g, 3, 4)
    add_edge!(g, 2, 3)

    # construct a MaxCut problem
    mc = MaxCut(g, [1, 3, 1, 4])

    # variables
    @test variables(mc) == [1, 2, 3, 4]
    @test num_variables(mc) == 4
    @test flavors(MaxCut) == [0, 1]

    # parameters
    @test parameters(mc) == [1, 3, 1, 4]
    @test set_parameters(mc, [1, 3, 4, 4]) == MaxCut(g, [1, 3, 4, 4])

    # evaluate
    @test evaluate(mc, [1, 0, 0, 1]) == -8
    @test evaluate(set_parameters(mc,[1,2,4,4]), [0, 1, 1, 0]) == -7
    @test findbest(mc, BruteForce()) == [[0, 0, 1, 0], [0, 1, 1, 0], [1, 0, 0, 1], [1, 1, 0, 1]] # in lexicographic order
end