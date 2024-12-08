using Test, ProblemReductions, Graphs

@testset "maxcut" begin
    # construct a graph
    edgs = [(1, 2), (1, 3), (3, 4), (2, 3)]
    g = SimpleGraph(4)
    for (i, j) in edgs
        add_edge!(g, i, j)
    end
    edgs_r = [(e.src, e.dst) for e in Graphs.edges(g)]
    @test ProblemReductions.cut_size(g, [0, 0, 1, 1]; weights=getindex.(Ref(Dict(zip(edgs, [1, 2, 3, 4]))), edgs_r)) == 6

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

    # solution_size
    @test solution_size(mc, [1, 0, 0, 1]) == SolutionSize(8, true)
    @test solution_size(set_weights(mc,[1,2,4,4]), [0, 1, 1, 0]) == SolutionSize(7, true)
    @test findbest(mc, BruteForce()) == [[0, 0, 1, 0], [0, 1, 1, 0], [1, 0, 0, 1], [1, 1, 0, 1]] # in lexicographic order
end