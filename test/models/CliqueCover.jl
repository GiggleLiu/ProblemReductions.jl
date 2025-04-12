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
    @test is_clique_cover([[1,0,1,0,0],[0,1,0,1,0],[0,0,0,0,0]],c) == false
    @test is_clique_cover([[1,0,1,0,0],[0,1,0,1,1]],c) == false
    @test ProblemReductions.is_clique(c,[1,0,1,0,0]) == true
    @test ProblemReductions.is_clique(c,[0,1,0,1,1]) == false
    @test ProblemReductions.is_clique(c,[1,0,1,0,1]) == true

    g1 = SimpleGraph(6)
    for (i,j) in [(1,3),(1,5),(1,6),(2,3),(2,4),(3,4),(3,5),(4,6),(5,6)]
        add_edge!(g1,i,j)
    end
    c1 = CliqueCover(g1,2)
    @test is_clique_cover([[1,0,0,0,1,1],[0,1,1,1,0,0]],c1) == true
    @test is_clique_cover([[1,0,1,0,1,0],[0,1,0,1,0,0]],c1) == false
    @test is_clique_cover([[1,0,1,0,1,0],[0,1,0,1,0,0],[0,0,0,0,0,0]],c1) == false
    @test ProblemReductions.is_clique(c1,[1,0,1,0,1,0]) == true
    c2 = CliqueCover(g1,3)
    @test is_clique_cover([[1,0,1,0,1,0],[0,1,0,1,0,0],[0,0,0,0,0,1]],c2) == true
    @test is_clique_cover([[1,0,1,0,1,0],[0,1,0,1,0,0],[0,0,0,0,0,0]],c2) == false
end