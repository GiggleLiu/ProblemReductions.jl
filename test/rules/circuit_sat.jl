using Test, ProblemReductions

@testset "circuit_sat" begin
    function verify(sat)
        reduction_results = reduceto(CircuitSAT, sat)
        circuit_tmp = reduction_results.target
        sol_circuit = findbest(circuit_tmp, BruteForce())
        s1 = Set(findbest(sat, BruteForce()))
        s2 = Set(unique(filter(sol -> sol !== nothing, extract_solution.(Ref(reduction_results), sol_circuit))))
        s3 = Set(extract_multiple_solutions(reduction_results, sol_circuit))
        return (s2 ⊆ s1) && (s3 == s1)
    end

    # Example 001: satisfiable 3-SAT
    x1 = BoolVar(:x1, false)
    nx1 = BoolVar(:x1, true)
    x2 = BoolVar(:x2, false)
    nx2 = BoolVar(:x2, true)
    x3 = BoolVar(:x3, false)
    nx3 = BoolVar(:x3, true)

    clause1 = CNFClause([x1, nx2, x3])
    clause2 = CNFClause([nx1, x2, nx3])
    clause3 = CNFClause([x1, nx2, nx3])
    clause4 = CNFClause([nx1, x2, x3])

    clause_lst = [clause1, clause2, clause3, clause4]
    sat01 = Satisfiability(CNF(clause_lst))

    @test reduction_complexity(CircuitSAT, sat01) == 1
    @test verify(sat01)

    # Example 002: satisfiable 3-SAT
    clause5 = CNFClause([nx1, x2, x3])
    clause6 = CNFClause([x1, nx2, x3])
    clause7 = CNFClause([x1, x2, nx3])
    sat02 = Satisfiability(CNF([clause5, clause6, clause7]))
    @test verify(sat02)

    # Example 003: satisfiable 3-SAT
    clause8 = CNFClause([x1, x2, x3])
    clause9 = CNFClause([nx1, nx2, nx3])
    sat03 = Satisfiability(CNF([clause8, clause9]))
    @test verify(sat03)
    
end