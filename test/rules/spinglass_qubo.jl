using Test, ProblemReductions, Graphs

@testset "qubo -> spinglass" begin
    qb = QUBO([2 1 -2; 1 2 -2; -2 -2 2])
    sg = reduceto(SpinGlass, qb)
    @test reduction_complexity(SpinGlass, qb) == 1
    res = findbest(target_problem(sg), BruteForce())
    @test sort(res) == sort([[1, 1, 1], [1, -1, -1], [-1, 1, -1], [-1, -1, -1]]) # in lexicographic order
    @test sort(extract_solution.(Ref(sg), res)) == sort([[0, 0, 0], [0, 1, 1], [1, 0, 1], [1, 1, 1]])

    qbr = reduceto(QUBO, target_problem(sg))
    @test reduction_complexity(QUBO, target_problem(sg)) == 1
    res2 = findbest(target_problem(qbr), BruteForce())
    @test sort(res2) == sort([[0, 0, 0], [0, 1, 1], [1, 0, 1], [1, 1, 1]])
    @test sort(extract_solution.(Ref(qbr), res2)) == sort([[1, 1, 1], [1, -1, -1], [-1, 1, -1], [-1, -1, -1]])
end