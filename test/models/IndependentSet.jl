using Test, ProblemReductions, Graphs

@testset "independentset" begin
    # construct two equivalent graphs
    g01 = SimpleGraph(4)
    add_edge!(g01, 1, 2) 
    add_edge!(g01, 1, 3)
    add_edge!(g01, 3, 4)
    add_edge!(g01, 2, 3)
    @test is_independent_set(g01, [0, 0, 0, 0])
    @test is_independent_set(g01, [1, 0, 0, 1])
    @test !is_independent_set(g01, [1, 1, 0, 0])

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

    # solution_size
    # Positive examples
    @test solution_size(IS_01, [1, 0, 0, 1]) == SolutionSize(2, true)
    @test solution_size(IS_01, [0, 1, 0, 1]) == SolutionSize(2, true)
    # a Negative example
    @test !solution_size(IS_01, [0, 1, 1, 0]).is_valid

    # test findbest function
    @test findbest(IS_01, BruteForce()) == [[1, 0, 0, 1], [0, 1, 0, 1]] # "1" is superior to "0"
    @test Set( findbest(IS_03, BruteForce()) ) == Set( [[1, 0, 1, 0, 1], [1, 0, 0, 1, 1]] )
    @test configuration_space_size(IS_01) ≈ 4
end

@testset "size terms" begin
    g01 = smallgraph(:diamond)
    IS_01 = IndependentSet(g01)
    cons = ProblemReductions.hard_constraints(IS_01)
    terms = ProblemReductions.local_solution_size(IS_01)
    @test length(terms) == 4
    for cfg in [[0, 1, 1, 0], [1, 0, 0, 1]]
        sz = ProblemReductions._size_eval(terms, cfg)
        e2 = ProblemReductions.solution_size(IS_01, cfg)
        @test (sz == e2.size) || (!ProblemReductions._is_satisfied(cons, cfg) && !e2.is_valid)
    end
end

@testset "energy based modeling" begin
    g01 = smallgraph(:diamond)
    problem = IndependentSet(g01)
    @test energy(problem, [0, 1, 1, 0]) > 1e4
    @test energy(problem, [1, 0, 0, 1]) == -2
    problem = IndependentSet(g01, randn(4))
    @test energy(problem, [0, 1, 1, 0]) == Inf
end
