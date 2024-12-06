using Test, ProblemReductions, Graphs
using ProblemReductions: SATColoringConstructor, add_clause!, Satisfiability, CNF, CNFClause

@testset "sat_coloring" begin |
    bool1 = BoolVar(:X)
    bool2 = BoolVar(:Y)
    clause1 = CNFClause([bool1, bool2])
    clause2 = CNFClause([bool1, ¬bool2])
    CNF1 = CNF([clause1, clause2])
    Sat1 = Satisfiability(CNF1)
    @test Sat1 isa Satisfiability
    result = reduceto(Coloring{3}, Sat1)
    @test result.posvertices == [4, 5]
    @test result.negvertices == [6, 7]
    @test target_problem(result) isa Coloring
    res = findbest(target_problem(result), BruteForce())
    backres = extract_solution.(Ref(result), res)
    @test unique(backres) == [[1, 0], [1, 1]]
end
