using ProblemReductions, Test, Graphs
using ProblemReductions: KSatisfiability,clauses
@testset "satisfiability" begin
    bv1 = BoolVar("x")
    bv2 = BoolVar("y")
    bv3 = BoolVar("z", true)    

    clause1 = CNFClause([bv1, bv2, bv3])
    clause2 = CNFClause([BoolVar("w"), bv1, BoolVar("x", true)])

    cnf_test = CNF([clause1, clause2])
    sat_test = Satisfiability(cnf_test)
    
    @test sat_test isa Satisfiability
    @test clauses(sat_test) == cnf_test.clauses
    
    @test is_kSAT(sat_test.cnf, 3)
    vars = ["x", "y", "z", "w"]
    @test variables(sat_test) == vars
    @test num_variables(sat_test) == 4
    @test problem_size(sat_test) == (; num_claues = 2, num_variables = 4)

    cfg = [1, 1, 1, 1]
    assignment = Dict(zip(vars, cfg))
    @test satisfiable(sat_test.cnf, assignment) == true
    @test energy(sat_test, cfg) == 0

    cfg = [0, 0, 1, 0]
    assignment = Dict(zip(vars, cfg))
    @test satisfiable(sat_test.cnf, assignment) == false
    @test energy(sat_test, cfg) == 1

    res = findbest(sat_test, BruteForce())
    @test length(res) == 14

    # Tests for KSatisfiability
    ksat_test = KSatisfiability{3}(cnf_test)
    @test clauses(ksat_test) == cnf_test.clauses
    @test ksat_test isa KSatisfiability
    @test variables(ksat_test) == vars
    @test num_variables(ksat_test) == 4

    cfg = [0, 1, 0, 1]
    assignment = Dict(zip(vars, cfg))
    @test satisfiable(ksat_test.cnf, assignment) == true
    @test energy(ksat_test, cfg) == 0
end