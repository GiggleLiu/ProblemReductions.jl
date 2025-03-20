using Test, ProblemReductions, Graphs

@testset "Biclique Cover" begin
    g = SimpleGraph(6)
    for (i,j) in [(1,5), (1,4), (2,5), (2,4), (3,6)]
        # g = ([{1,2,3}, {4,5,6}], [(1,4), (1,5), (2,4), (2,5), (3,6)])
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
    @test problem_size(bc) == (num_vertices=6, num_edges=5, k=2)
    bc_matrix = ProblemReductions.biclique_cover_from_matrix([1 1 0;1 1 0;0 0 1],2,UnitWeight(6))
    @test bc_matrix == bc
    # constraints interfaces
    #@test constraints(bc)[1] == ProblemReductions.LocalConstraint(2, [1, 4], [false,false,false,true])
    #@test objectives(bc) == [LocalSolutionSize(2, [1, 2, 3, 4, 5, 6], [0, 1, 2, 3, 4, 5])]
    #@test energy_mode(BicliqueCover) == SmallerSizeIsBetter()
    @test is_biclique_cover(bc, [[1,1,0,1,1,0],[0,0,1,0,0,1]]) == true
    @test is_biclique_cover(bc, [[1,1,0,1,1,0],[0,0,1,0,0,0]]) == false
    @test ProblemReductions.is_satisfied(bc,[[1,1,0,1,1,0],[0,0,1,0,0,1]]) == true
    @test solution_size(bc, [[1,1,0,1,1,0],[0,0,1,0,0,1]]) == Solution_Size(2, true)
    @test solution_size(bc, [[1,1,0,1,1,0],[0,0,1,0,0,0]]) == Solution_Size(2, false)
end
