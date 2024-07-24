using Test, ProblemReductions, Graphs

@testset "Vertex Covering" begin
    g = SimpleGraph(4)
    add_edge!(g, 1, 2)
    add_edge!(g, 1, 3)
    add_edge!(g, 3, 4)
    add_edge!(g, 2, 3)
    
    # construct a VertexCovering problem
    vc = VertexCovering(g, [1, 3, 1, 4])
    @test variables(vc) == [1, 2, 3, 4]
    @test num_variables(vc) == 4
    @test flavors(VertexCovering) == [0, 1]
    @test parameters(vc) == [1, 3, 1, 4]
    @test set_parameters(vc, [1, 3, 4, 4]) == VertexCovering(g, [1, 3, 4, 4])

    # evaluate
    @test evaluate(vc, [1, 0, 0, 1]) == typemax(Int)
    @test evaluate(set_parameters(vc,[1,2,4,1]), [0, 1, 1, 0]) == 6
    @test is_vertex_covering(vc.graph, [1, 0, 0, 1]) == false
    
    #findbest
    @test findbest(vc, BruteForce()) == [[1,0,1,0]] 
end