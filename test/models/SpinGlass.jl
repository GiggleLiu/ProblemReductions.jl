using ProblemReductions, Test, Graphs

@testset "spinglass" begin
    # construct an AND gate
    g = SimpleGraph(3)
    add_edge!(g, 1, 2)
    add_edge!(g, 1, 3)
    add_edge!(g, 2, 3)
    sg = SpinGlass(g, [1, -2, -2], [1, 1, -2])
    @test problem_size(sg) == (; num_vertices = 3, num_edges = 3)

    # variables
    @test variables(sg) == [1, 2, 3]
    @test num_variables(sg) == 3
    @test flavors(sg) == (1, -1)
    @test num_flavors(sg) == 2

    # weights
    @test ProblemReductions.weights(sg) == [1, -2, -2, 1, 1, -2]
    @test set_weights(sg, [1, 2, 2, -1, -1, -2]) == SpinGlass(g, [1, 2, 2], [-1, -1, -2])

    @test energy(sg, [1, 1, 1]) == -3
    configs = findbest(sg, BruteForce())
    for cfg in configs
        @test cfg[3] == cfg[1] & cfg[2]
    end
end


@testset "energyterms - spinglass" begin
    g01 = smallgraph(:diamond)
    sg = SpinGlass(g01, [1, -2, -2, 1, 2], [1, 1, -2, -2])
    terms = ProblemReductions.energy_terms(sg)
    for cfg in [[-1, 1, 1, -1], [1, -1, -1, 1]]
        @test ProblemReductions.energy_eval_byid(terms, (1 .- cfg) .÷ 2 .+ 1) == ProblemReductions.energy(sg, cfg)
    end
end