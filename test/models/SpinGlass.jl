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
    @test flavors(sg) == (0, 1)
    @test num_flavors(sg) == 2
    @test flavor_names(sg) == ['↑', '↓']

    # weights
    @test ProblemReductions.weights(sg) == [1, -2, -2, 1, 1, -2]
    @test set_weights(sg, [1, 2, 2, -1, -1, -2]) == SpinGlass(g, [1, 2, 2], [-1, -1, -2])

    @test solution_size(sg, ProblemReductions.name2config(sg, ['↑', '↑', '↑'])) == SolutionSize(-3, true)
    configs = findbest(sg, BruteForce())
    for cfg in configs
        @test cfg[3] == cfg[1] & cfg[2]
    end
end

@testset "size terms - spinglass" begin
    g01 = smallgraph(:diamond)
    sg = SpinGlass(g01, [1, -2, -2, 1, 2], [1, 1, -2, -2])
    cons = ProblemReductions.constraints(sg)
    terms = ProblemReductions.local_solution_size(sg)
    for cfg in [ProblemReductions.name2config(sg, ['↓', '↑', '↑', '↓']), ProblemReductions.name2config(sg, ['↑', '↓', '↓', '↑'])]
        @test ProblemReductions._size_eval(terms, cfg) == ProblemReductions.solution_size(sg, cfg).size
        @test ProblemReductions.is_satisfied(sg, cfg) == ProblemReductions.solution_size(sg, cfg).is_valid
    end
    @test energy(sg, ProblemReductions.name2config(sg, ['↓', '↑', '↑', '↓'])) == -4
end