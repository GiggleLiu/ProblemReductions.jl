using Test, ProblemReductions, Graphs

@testset "Independent Set to Vertex Covering" begin
    g = SimpleGraph(4)
    for (i, j) in [(1, 2), (1, 3), (3, 4), (2, 3)]
        add_edge!(g, i, j)
    end
    IS = IndependentSet(g)  # define an independent set problem
    VC = reduceto(VertexCovering, IS)  # reduce the independent set problem to a vertex covering problem
    @test target_problem(VC) ==  VertexCovering(g)
    @test reduceto(VertexCovering, IS) == VC
    sol = findbest(IS, BruteForce())
    @test extract_solution(VC, sol) == [[0,1,1,0],[1,0,1,0]]
end
