using Test, ProblemReductions, Graphs
using Graphs: SimpleEdge
using ProblemReductions: vertexcovering2setcovering

@testset "VertexCoveing_SetCovering" begin
    g = SimpleGraph(4)
    add_edge!(g, 1, 2) # no.1
    add_edge!(g, 1, 3) # no.2
    add_edge!(g, 3, 4) # no.4
    add_edge!(g, 2, 3) # no.3

    # construct a VertexCovering problem
    vc = VertexCovering(g, [1, 3, 1, 4])
    sc,edgelabel = vertexcovering2setcovering(vc)
    @test reduceto(SetCovering, vc) == ReductionVertexCoveringToSetCovering(sc, edgelabel)
    @test target_problem(reduceto(SetCovering, vc)) == reduceto(SetCovering, vc).setcovering
    @test sc == SetCovering([[1,2],[1,3],[2,3,4],[4]], [1, 3, 1, 4])
    @test edgelabel == Dict(SimpleEdge(2, 3) => 3, SimpleEdge(1, 3) => 2, SimpleEdge(1, 2) => 1, SimpleEdge(3, 4) => 4) # in lexicographic order
    @test findbest(sc, BruteForce()) == [[1,0,1,0]]
    @test findbest(vc, BruteForce()) == [[1,0,1,0]]
    @test findbest(vc, BruteForce()) == findbest(sc, BruteForce())
    @test extract_solution(reduceto(SetCovering, vc), [1,0,1,0]) == [1,0,1,0]
end