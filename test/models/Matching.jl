using Test, ProblemReductions, Graphs
using ProblemReductions: is_matching

@testset "Matching" begin
    #test1
    g1 = smallgraph(:petersen)
    m1 = Matching(g1, [1, 0, 0, 3, 0, 0, 0, 0, 1, 2, 1, 2, 1, 3, 1])
    @test m1 isa Matching
    @test variables(m1) == [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15]
    @test num_variables(m1) == 15
    @test flavors(m1) == (0, 1)
    @test problem_size(m1) == (; num_vertices = 10, num_edges = 15)

    #test2 
    g2 = SimpleGraph(4)
    add_edge!(g2, 1, 2)
    add_edge!(g2, 1, 3)
    add_edge!(g2, 2, 4)
    add_edge!(g2, 3, 4)
    m2 = Matching(g2, [1, 0, 0, 1])
    @test set_weights(m2, [1, 1, 0, 0]) == Matching(g2, [1, 1, 0, 0])
    @test variables(m2) == [1, 2, 3, 4]
    @test num_variables(m2) == 4
    @test flavors(m2) == (0, 1)
    @test ProblemReductions.weights(m2) == [1, 0, 0, 1]
    @test ProblemReductions.set_weights(m2, [1, 1, 0, 0]) == Matching(g2, [1, 1, 0, 0])
    @test is_matching(m2.graph, [1, 0, 0, 1]) == true
    @test is_matching(m2.graph, [1, 1, 0, 0]) == false
    @test energy(m2, [1, 0, 0, 1]) == 2
    @test energy(m2, [1, 1, 0, 0]) > 1000
    @test sort(findbest(m2, BruteForce()))== sort([[0,0,0,0],[0,0,1,0],[0,1,0,0],[0,1,1,0]])
end