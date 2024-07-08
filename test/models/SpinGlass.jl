using ProblemReductions, Test, Graphs

@testset "spinglass" begin
    # construct an AND gate
    g = SimpleGraph(3)
    add_edge!(g, 1, 2)
    add_edge!(g, 1, 3)
    add_edge!(g, 2, 3)
    sg = SpinGlass(g, [1, -2, -2], [1, 1, -2])
    @test num_terms(sg) == 6
    @test num_variables(sg) == 3
    @test num_flavors(sg) == 2
    @test evaluate(sg, [0, 0, 0]) == -3
    configs = findbest(sg)
    for cfg in configs
        @test cfg[3] == cfg[1] & cfg[2]
    end
end