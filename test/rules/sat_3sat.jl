using Test, ProblemReductions

@testset "sat_3sat" begin
    # Example 001 (Satisfiability => 3-Satisfiability)
    bv1 = BoolVar(:x, false)
    bv2 = BoolVar(:y, true)
    bv3 = BoolVar(:z, false)
    bv4 = BoolVar(:w, false)
    
    clause1 = CNFClause([bv1])
    clause2 = CNFClause([bv2, bv3])
    clause3 = CNFClause([bv1, bv2, bv3, bv4])

    cnf01 = CNF([clause1, clause2, clause3])
    sat01 = Satisfiability(cnf01)

    reduction_result = reduceto(KSatisfiability{3}, sat01)
    original_sol = findbest(sat01, BruteForce() )
    new_sol = findbest(reduction_result.sat_target, BruteForce() )
    @test original_sol == extract_multiple_solutions(reduction_result, new_sol)
    @test issubset(original_sol, extract_solution.(Ref(reduction_result), new_sol) )

    # Example 002 (KSatisfiability => General Satisfiability)
    ksat01 = reduction_result.sat_target
    reduction_result_02 = reduceto(Satisfiability, ksat01)
    @test reduction_result_02.sat_target == Satisfiability( ksat01.cnf )
    @test target_problem( reduction_result_02 ) == Satisfiability( ksat01.cnf )
    @test findbest(ksat01, BruteForce() ) == extract_multiple_solutions( reduction_result_02, findbest(reduction_result_02.sat_target, BruteForce() ) )
    @test issubset( findbest(ksat01, BruteForce() ), unique( extract_solution.( Ref(reduction_result_02), findbest(reduction_result_02.sat_target, BruteForce() ) ) ) )

    # Example 003 (Satisfiability => 3-Satisfiability) 
    bv5 = BoolVar(:v, false)
    clause5 = CNFClause([bv1, bv2, bv3])
    clause6 = CNFClause([bv1, bv2, bv3, bv4, bv5])

    cnf02 = CNF([clause5, clause6])
    sat02 = Satisfiability(cnf02)

    reduction_result_03 = reduceto(KSatisfiability{3}, sat02)
    @test Set( findbest(sat02, BruteForce() ) ) == Set( extract_multiple_solutions( reduction_result_03, findbest(reduction_result_03.sat_target, BruteForce() ) ) )
    @test issubset( Set( findbest(sat02, BruteForce() ) ), Set( unique( extract_solution.( Ref(reduction_result_03), findbest(reduction_result_03.sat_target, BruteForce() ) ) ) ) )
end