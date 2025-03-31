using Test, ProblemReductions, Graphs

@testset "BruteForce" begin
    graph = smallgraph(:petersen)
    problem = IndependentSet(graph)
    solver = BruteForce()
    res = findbest(problem, solver)
    @test res == [[0, 0, 1, 0, 1, 1, 1, 0, 0, 0], [1, 0, 0, 1, 0, 0, 1, 1, 0, 0], [0, 1, 0, 0, 1, 0, 0, 1, 1, 0], [0, 1, 0, 1, 0, 1, 0, 0, 0, 1], [1, 0, 1, 0, 0, 0, 0, 0, 1, 1]]
    solver = BruteForce()
    res = findbest(problem, solver)
    @test res == [[0, 0, 1, 0, 1, 1, 1, 0, 0, 0], [1, 0, 0, 1, 0, 0, 1, 1, 0, 0], [0, 1, 0, 0, 1, 0, 0, 1, 1, 0], [0, 1, 0, 1, 0, 1, 0, 0, 0, 1], [1, 0, 1, 0, 0, 0, 0, 0, 1, 1]]
end