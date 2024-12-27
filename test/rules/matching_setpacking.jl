using Test, ProblemReductions, Graphs

@testset "matching_setpacking" begin

    # UnitWeight Graph
    g1 = SimpleGraph(4)
    for (i, j) in [(1, 2), (1, 3), (3, 4), (2, 3)]
        add_edge!(g1, i, j)
    end
    Matching1 = Matching(g1)
    SP1 = reduceto(SetPacking, Matching1)
    @test target_problem(SP1) == SP1.setpacking
    @test target_problem(SP1) == SetPacking([[1,2], [1,3],[2,3] ,[3,4]], [1, 1, 1, 1])
    sol = findbest(SP1.setpacking, BruteForce())
    @test extract_solution(SP1, sol) == sol

    # Weighted Graph
    g2 = SimpleGraph(4)
    for (i, j) in [(1, 2), (1, 3), (3, 4), (2, 3)]
        add_edge!(g2, i, j)
    end
    Matching2 = Matching(g2, [1, 2, 3, 4])
    SP2 = reduceto(SetPacking, Matching2)
    @test target_problem(SP2) == SP2.setpacking
    @test target_problem(SP2) == SetPacking([[1,2], [1,3], [2,3], [3,4]], [1, 2, 3, 4])
    sol1 = findbest(SP2.setpacking, BruteForce())
    sol2 = findbest(Matching2,BruteForce())
    @test extract_solution(SP2, sol1) == sol2
end