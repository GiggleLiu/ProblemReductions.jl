using ProblemReductions, Test, Graphs

@testset "spinglass" begin
    # construct an AND gate
    g = SimpleGraph(3)
    add_edge!(g, 1, 2)
    add_edge!(g, 1, 3)
    add_edge!(g, 2, 3)
    sg = SpinGlass(g, [1, -2, -2], [1, 1, -2])

    # variables
    @test variables(sg) == [1, 2, 3]
    @test num_variables(sg) == 3
    @test flavors(sg) == [0, 1]
    @test num_flavors(sg) == 2

    # parameters
    @test parameters(sg) == [1, -2, -2, 1, 1, -2]
    @test set_parameters(sg, [1, 2, 2, -1, -1, -2]) == SpinGlass(g, [1, 2, 2], [-1, -1, -2])

    @test evaluate(sg, [0, 0, 0]) == -3
    configs = findbest(sg, BruteForce())
    for cfg in configs
        @test cfg[3] == cfg[1] & cfg[2]
    end
end
