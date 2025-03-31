using Test, ProblemReductions, Graphs

@testset "Biclique Cover" begin
    g = SimpleGraph(6)
    for (i,j) in [(1,5), (1,4), (2,5), (2,4), (3,6)]
        # g = ([{1,2,3}, {4,5,6}], [(1,4), (1,5), (2,4), (2,5), (3,6)])
        add_edge!(g, i, j)
    end
    bc = BicliqueCover(g,[1,2,3],2)
    # variable and weight interfaces
    @test num_variables(bc) == 12
    @test num_flavors(bc) == 2
    @test num_flavors(BicliqueCover) == 2
    @test problem_size(bc) == (num_vertices=6, num_edges=5, k=2)
    bc_matrix = ProblemReductions.biclique_cover_from_matrix([1 1 0;1 1 0;0 0 1],2)
    @test bc_matrix == bc
    # constraints interfaces
    @test energy_mode(BicliqueCover) == SmallerSizeIsBetter()
    @test ProblemReductions.is_biclique([1,1,0,1,1,0],bc) == true
    @test ProblemReductions.is_bipartite(g,[1,2,3]) == true
    @test ProblemReductions.is_bipartite(g,[1,2,3,4]) == false
    @test is_biclique_cover(bc, [[1,1,0,1,1,0],[0,0,1,0,0,1]]) == true
    @test is_biclique_cover(bc, [[1,1,0,1,1,0],[0,0,1,0,0,0]]) == false
    @test ProblemReductions.is_k_biclique_cover(bc, [[1,1,0,1,1,0],[0,0,1,0,0,1]]) == true
    @test ProblemReductions.is_satisfied(bc,[[1,1,0,1,1,0],[0,0,1,0,0,1]]) == true
    @test solution_size(bc, [[1,1,0,1,1,0],[0,0,1,0,0,1]]) == ProblemReductions.SolutionSize(6, true)
    @test solution_size(bc, [[1,1,0,1,1,0],[0,0,1,0,0,0]]) == ProblemReductions.SolutionSize(5, false)
end
