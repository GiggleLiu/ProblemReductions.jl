using Test, ProblemReductions, Graphs

@testset "independentset" begin
    # construct two equivalent graphs
    g01 = SimpleGraph(4)
    add_edge!(g01, 1, 2) 
    add_edge!(g01, 1, 3)
    add_edge!(g01, 3, 4)
    add_edge!(g01, 2, 3)

    g02 = SimpleGraph(4)
    add_edge!(g02, 1, 3) 
    add_edge!(g02, 1, 2)
    add_edge!(g02, 2, 3)
    add_edge!(g02, 3, 4)

    g03 = HyperGraph(5, [[1, 2], [2, 3, 4]])

    # construct corresponding IndependentSet problems
    IS_01 = IndependentSet(g01)
    @test set_weights(IS_01, [1, 2, 2, 1]) == IndependentSet(g01, [1, 2, 2, 1])
    IS_02 = IndependentSet(g02)
    IS_03 = IndependentSet(g03)
    @test IS_01 == IS_02
    @test problem_size(IS_01) == (; num_vertices = 4, num_edges = 4)
    @test problem_size(IS_03) == (; num_vertices = 5, num_edges = 2)

    # variables
    @test variables(IS_01) == [1, 2, 3, 4]
    @test num_variables(IS_01) == 4
    @test flavors(IndependentSet) == (0, 1)

    # energy
    # Positive examples
    @test energy(IS_01, [1, 0, 0, 1]) == -2
    @test energy(IS_01, [0, 1, 0, 1]) == -2
    # a Negative example
    @test energy(IS_01, [0, 1, 1, 0]) > 1000

    # test findbest function
    @test findbest(IS_01, BruteForce()) == [[1, 0, 0, 1], [0, 1, 0, 1]] # "1" is superior to "0"
    @test Set( findbest(IS_03, BruteForce()) ) == Set( [[1, 0, 1, 0, 1], [1, 0, 0, 1, 1]] )
    @test configuration_space_size(IS_01) ≈ 4
end

@testset "energyterms" begin
    g01 = smallgraph(:diamond)
    IS_01 = IndependentSet(g01)
    terms = ProblemReductions.energy_terms(IS_01)
    @test length(terms) == 9
    for cfg in [[0, 1, 1, 0], [1, 0, 0, 1]]
        e1 = ProblemReductions.energy_eval_byid(terms, cfg .+ 1)
        e2 = ProblemReductions.energy(IS_01, cfg)
        @test (e1 == e2) || (e1 > 1e4 && e2 > 1e4)
    end
end