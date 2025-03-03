using Test, ProblemReductions, Graphs

@testset "Biclique Cover" begin
    g = SimpleGraph(4)
    for (i,j) in [(1,2), (1,3), (3,4), (2,3), (1,4)]
        add_edge!(g, i, j)
    end
    bc = BicliqueCover(g,2)
    @test num_variables(bc) == 8
    @test flavors(BicliqueCover) == (0, 1)
    @test ProblemReductions.weights(bc) == fill(1,nv(bc.graph))
    new_weights = [1,2,3,4,5,6,7,8]
    @test set_weights(bc,new_weights) == BicliqueCover(bc.graph,bc.k,new_weights)
end