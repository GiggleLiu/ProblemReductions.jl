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

    @test solution_size(sg, [1, 1, 1]) == SolutionSize(-3, true)
    configs = findbest(sg, BruteForce())
    for cfg in configs
        @test cfg[3] == cfg[1] & cfg[2]
    end
end


@testset "size terms - spinglass" begin
    g01 = smallgraph(:diamond)
    sg = SpinGlass(g01, [1, -2, -2, 1, 2], [1, 1, -2, -2])
    terms = ProblemReductions.size_terms(sg)
    for cfg in [[-1, 1, 1, -1], [1, -1, -1, 1]]
        @test ProblemReductions.size_eval_byid(terms, (1 .- cfg) .÷ 2 .+ 1) == ProblemReductions.solution_size(sg, cfg)
    end
    @test energy(sg, [-1, 1, 1, -1]) == -4
end