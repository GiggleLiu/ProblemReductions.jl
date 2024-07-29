using Test, ProblemReductions, Graphs
using ProblemReductions: sat2coloring, CNF2Graph, OR_gate, OR_gate_gadget,one,var_vertex
@testset "sat_coloring" begin 
    bool1 = BoolVar("X")
    bool2 = BoolVar("Y")
    bool3 = BoolVar("Z")
    clause1 = CNFClause([bool1,bool2,bool3])
    CNF1 = CNF([clause1])
    Sat1 = Satisfiability(CNF1)
    @test Sat1 isa Satisfiability
    @test reduceto(Coloring{3},Sat1) == ReductionSatToColoring(Coloring{3}(SimpleGraph{Int64}(16), UnitWeight(16)), Dict("X" => 1, "Y" => 2, "Z" => 3))
end