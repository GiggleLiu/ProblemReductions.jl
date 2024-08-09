using Test, ProblemReductions, Graphs
using ProblemReductions: SATColoringConstructor, add_clause!, Satisfiability, CNF, CNFClause

@testset "sat_coloring" begin |
    bool1 = BoolVar(:X)
    bool2 = BoolVar(:Y)
    clause1 = CNFClause([bool1, bool2])
    CNF1 = CNF([clause1])
    Sat1 = Satisfiability(CNF1)
    @test Sat1 isa Satisfiability
    result = reduceto(Coloring{3}, Sat1)
    @test reduction_complexity(Coloring{3}, Sat1) == 1
    expected_varlabel = Dict{BoolVar{Symbol}, Int64}(¬bool1 => 6, ¬bool2 => 7,bool2 => 5, bool1 => 4) 
    @test result.varlabel == expected_varlabel
    @test target_problem(result) isa Coloring
end
