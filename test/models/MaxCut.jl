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
    @test set_weights(mc, [1, 3, 2, 4]) == MaxCut(g, [1, 3, 2, 4])
    @test problem_size(mc) == (; num_vertices = 4, num_edges = 4)

    # variables
    @test variables(mc) == [1, 2, 3, 4]
    @test num_variables(mc) == 4
    @test flavors(MaxCut) == (0, 1)
    @test flavors(mc) == (0, 1)
    @test num_flavors(mc) == 2
    # weights
    @test ProblemReductions.weights(mc) == [1, 3, 1, 4]
    @test set_weights(mc, [1, 3, 4, 4]) == MaxCut(g, [1, 3, 4, 4])

    # energy
    @test energy(mc, [1, 0, 0, 1]) == -8
    @test energy(set_weights(mc,[1,2,4,4]), [0, 1, 1, 0]) == -7
    @test findbest(mc, BruteForce()) == [[0, 0, 1, 0], [0, 1, 1, 0], [1, 0, 0, 1], [1, 1, 0, 1]] # in lexicographic order
end