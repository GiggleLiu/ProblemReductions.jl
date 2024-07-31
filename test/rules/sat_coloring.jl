using Test, ProblemReductions, Graphs
using ProblemReductions: sat2coloring, CNF2Graph, OR_gate, add_coloring_or_gadget!, tablegadget, var_vertex

@testset "sat_coloring" begin |
    bool1 = BoolVar(:X)
    bool2 = BoolVar(:Y)
    bool3 = BoolVar(:Z)
    clause1 = CNFClause([bool1, bool2, bool3])
    CNF1 = CNF([clause1])
    Sat1 = Satisfiability(CNF1)
    
    @test Sat1 isa Satisfiability
    
    result = reduceto(Coloring{3}, Sat1)
    
    expected_coloring = Coloring{3}(SimpleGraph{Int64}(16), UnitWeight(16))
    expected_varlabel = Dict{String, Int64}("X" => 1, "Y" => 2, "Z" => 3)
    expected_result = ReductionSatToColoring(expected_coloring, expected_varlabel)
end
