using ProblemReductions, Test, Graphs

@testset "qubo" begin
    # construct several QUBO problems
    Q01 = [1. 0 0; 0 1 0; 0 0 1]
    q01 = QUBO(Q01)
    @test q01 isa QUBO

    # QUBO from Graph
    graph = SimpleGraph(3)
    q03 = QUBO(graph, Float64[], [1., 1., 1.])
    @test q01 == q03
    @test problem_size(q01) == (; num_variables = 3)
    
    # variables
    @test variables(q01) == [1, 2, 3]
    @test num_variables(q01) == 3
    @test flavors(q01) == (0, 1)
    @test num_flavors(q01) == 2

    # energy
    @test energy(q01, [0, 0, 0]) == 0
    @test energy(q01, [1, 1, 0]) == 2
    @test findbest(q01, BruteForce()) == [[0, 0, 0]]

    # the OR gadget
    q04 = QUBO([2 1 -2; 1 2 -2; -2 -2 2])
    @test sort(findbest(q04, BruteForce())) == [[0, 0, 0], [0, 1, 1], [1, 0, 1], [1, 1, 1]]
end