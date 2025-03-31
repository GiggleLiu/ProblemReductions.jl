using Test, ProblemReductions, Graphs

@testset "CliqueCover" begin
    g = SimpleGraph(5)
    for (i,j) in [(1,3),(1,5),(2,3),(2,4),(3,5)]
        add_edge!(g,i,j)
    end
    c = CliqueCover(g,2)
    @test num_variables(c) == 5 * 2
    @test num_flavors(c) == 2
    @test problem_size(c) == (; num_vertices=5, num_edges=5, k=2)
    @test Base.:(==)(c, CliqueCover(g,2))
    @test energy_mode(c) == SmallerSizeIsBetter()
    @test is_clique_cover([[1,0,1,0,1],[0,1,0,1,0]],c) == true
    @test ProblemReductions.is_clique(c,[1,0,1,0,1]) == true
end