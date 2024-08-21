using Test, ProblemReductions, Graphs

@testset "sat_independentset" begin
    function verify(sat)
        reduction_results = reduceto(IndependentSet, sat)
        IS_tmp = reduction_results |> target_problem
        sol_IS = findbest(IS_tmp, BruteForce())
        s1 = Set(findbest(sat, BruteForce()))
        s2 = Set( unique( extract_solution.(Ref(reduction_results), sol_IS) ) )
        s3 = Set(extract_multiple_solutions(reduction_results, sol_IS))
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

    @test reduction_complexity(IndependentSet, sat01) == 1
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

    # Example 004: unsatisfiable 3-SAT (trivial example)
    clause10 = CNFClause([x1, x1, x1])
    clause11 = CNFClause([nx1, nx1, nx1])
    sat04 = Satisfiability(CNF([clause10, clause11]))
    @test verify(sat04)

    # Example 005: unsatisfiable 1-SAT (equivalent with example 004)
    sat05 = Satisfiability(CNF([CNFClause([x1]), CNFClause([nx1])]))
    @test verify(sat05)

    # Example 006: unsatisfiable 2-SAT
    sat06 = Satisfiability(CNF([CNFClause([x1, x2]), CNFClause([x1, nx2]), CNFClause([nx1, x2]), CNFClause([nx1, nx2])]))
    @test verify(sat06)

    # Example 007: satisfiable 2-SAT
    sat07 = Satisfiability(CNF([CNFClause([x1, x2]), CNFClause([x1, nx2]), CNFClause([nx1, x2])]))
    @test verify(sat07)
end