using ProblemReductions, Test, Graphs
using ProblemReductions: BoolVar, CNFClause, CNF, Satisfiability, is_kSAT, variables

@testset "satisfiability" begin
    bv1 = BoolVar("x")
    bv2 = BoolVar("y")
    bv3 = BoolVar("z", true)    

    clause1 = CNFClause([bv1, bv2, bv3])
    clause2 = CNFClause([BoolVar("w"), bv1, BoolVar("x", true)])

    cnf_test = CNF([clause1, clause2])

    sat_test = Satisfiability(cnf_test)

    @test sat_test isa Satisfiability
    @test is_kSAT(sat_test) == 3
    @test Set( variables(sat_test) ) == Set( [1, 2, 3, 4] )
    @test num_variables(sat_test) == 4
end