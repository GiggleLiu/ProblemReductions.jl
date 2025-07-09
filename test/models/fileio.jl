using Test, ProblemReductions, Graphs
using JSON

@testset "fileio" begin
    petersen = smallgraph(:petersen)
    k32 = SimpleGraph(5)
    for (i, j) in [(1, 4), (1, 5), (2, 4), (2, 5), (3, 4), (3, 5)]
        add_edge!(k32, i, j)
    end
    circuit = @circuit begin
        c = x ∧ y
        d = x ∨ (c ∧ ¬z)
    end
    ProblemReductions.@bools a b c
    problems = [
        CircuitSAT(circuit),
        SpinGlass(petersen, rand([-1, 1], ne(petersen)), rand([-1, 1], nv(petersen))),
        Coloring{3}(petersen),
        KSatisfiability{2}((a ∨ b) ∧ (¬b ∨ c)),
        Matching(petersen),
        MaxCut(petersen, rand([-1, 1], ne(petersen))),
        MaximalIS(petersen),
        PaintShop(["a", "b", "a", "b"]),
        Factoring(2, 2, 6),
        QUBO([1.0 0.5; 0.5 1.0]),
        BinaryMatrixFactorization(BitMatrix([1 0; 0 1]), 2),
        BicliqueCover(k32, [1,2,3], 2),
        IndependentSet(petersen),
        DominatingSet(petersen),
        SetPacking([[1, 2], [2, 3], [3, 4]]),
        SetCovering([[1, 2, 3], [2, 4], [1, 4]]),
        VertexCovering(petersen),
        Satisfiability((a ∨ ¬b) ∧ (b ∨ c)),
    ]
    for problem in problems
        test_file = tempname() * ".json"
        ProblemReductions.writejson(test_file, problem)
        problem_restored = ProblemReductions.readjson(test_file)
        @test problem_restored == problem
    end
end