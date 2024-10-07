using Test, ProblemReductions, Graphs

@testset "dominatingset" begin
    # construct two equivalent graphs
    g01 = SimpleGraph(5)
    add_edge!(g01, 1, 2)
    add_edge!(g01, 2, 3)
    add_edge!(g01, 3, 4)
    add_edge!(g01, 4, 5)

    g02 = SimpleGraph(5)
    add_edge!(g02, 4, 5)
    add_edge!(g02, 1, 2)
    add_edge!(g02, 3, 4)
    add_edge!(g02, 2, 3)
    
    # construct corresponding DominatingSet problems
    DS_01 = DominatingSet(g01)
    DS_02 = DominatingSet(g02)
    @test DS_01 == DS_02

    # variables
    @test variables(DS_01) == [1, 2, 3, 4, 5]
    @test num_variables(DS_01) == 5
    @test flavors(DominatingSet) == [0, 1]
    @test problem_size(DS_01) == (; num_vertices = 5, num_edges = 4)

    # energy
    # Positive examples
    @test energy(DS_01, [1, 0, 1, 0, 1]) == 3
    @test energy(DS_01, [0, 1, 0, 1, 0]) == 2
    @test energy(DS_01, [1, 1, 1, 1, 0]) == 4
    # Negative examples
    @test energy(DS_01, [0, 1, 1, 0, 0]) == 5
    @test energy(DS_01, [1, 0, 0, 0, 1]) == 5
    # findbest function
    @test findbest(DS_01, BruteForce()) == [[1, 0, 0, 1, 0], [0, 1, 0, 1, 0], [0, 1, 0, 0, 1]]
end