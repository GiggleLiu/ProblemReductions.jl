using ProblemReductions, Test, Graphs
using ProblemReductions:  is_maximal_independent_set

@testset "Maximal_IS" begin
    # test1 
    g = smallgraph(:petersen)
    mis1 = MaximalIS(g)
    @test problem_size(mis1) == (; num_vertices = 10, num_edges = 15)
    @test mis1 isa MaximalIS
    @test variables(mis1) == [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
    @test num_variables(mis1) == 10
    @test flavors(mis1) == [0, 1]
    @test num_flavors(mis1) == 2
    @test ProblemReductions.weights(mis1) == [1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
    @test ProblemReductions.set_weights(mis1, [1, 5, 1, 4, 1, 3, 1, 2, 1, 2]) == MaximalIS(g,[1, 5, 1, 4, 1, 3, 1, 2, 1, 2])

    #test2
    g = SimpleGraph(4)
    add_edge!(g, 1, 2)
    add_edge!(g, 1, 3)
    add_edge!(g, 3, 4)
    add_edge!(g, 2, 3)
    mis2 = MaximalIS(g)
    @test mis2 isa MaximalIS
    @test variables(mis2) == [1, 2, 3, 4]
    @test num_variables(mis2) == 4
    @test flavors(MaximalIS) == [0, 1]
    @test ProblemReductions.weights(mis2) == [1, 1, 1, 1]
    mis2 =  set_weights(mis2, [1, 2, 1, 2]) 
    @test mis2 == MaximalIS(g,[1, 2, 1, 2])
    @test is_maximal_independent_set(mis2.graph, [1, 0, 0, 1]) == true
    @test energy(mis2, [1, 0, 0, 1]) == -3
    mis2 =  set_weights(mis2, [-2, 1, 1, 3])
    @test energy(mis2, [1, 0, 0, 1]) == -1
    @test energy(mis2,[0, 1, 1, 0]) > 1000
    @test energy(mis2,[0, 1, 0, 0]) > 1000
    @test is_maximal_independent_set(mis2.graph, [0, 0, 1, 0]) == true
    @test sort(findbest(mis2, BruteForce())) == sort([[0, 1, 0, 1]]) 
end