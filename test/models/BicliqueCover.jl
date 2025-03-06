using Test, ProblemReductions, Graphs

@testset "Biclique Cover" begin
    g = SimpleGraph(6)
    for (i,j) in [(1,5), (1,4), (2,5), (2,4), (3,6)]
        add_edge!(g, i, j)
    end
    bc = BicliqueCover(g,2)
    # variable and weight interfaces
    @test num_variables(bc) == 12
    @test flavors(BicliqueCover) == (0, 1)
    @test ProblemReductions.weights(bc) == fill(1,nv(bc.graph))
    new_weights = [1,2,3,4,5,6]
    @test set_weights(bc,new_weights) == BicliqueCover(bc.graph,bc.k,new_weights)
    new_weights_error = [1,2,3,4,5]
    @test_throws AssertionError set_weights(bc,new_weights_error)
    # constraints
    # is_biclique_cover not yet implemented
    @test is_biclique_cover(bc, [1,1,0,1,1,0,0,0,1,0,0,1]) == true
end