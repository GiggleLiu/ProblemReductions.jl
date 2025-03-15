using Test, ProblemReductions, Graphs

@testset "BruteForce" begin
    graph = smallgraph(:petersen)
    problem = IndependentSet(graph)
    solver = BruteForce()
    res = solve(solver, problem)
    solver = BruteForce()
    res = solve(solver, problem)
end