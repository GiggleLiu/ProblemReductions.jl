using Test, ProblemReductions, Graphs

@testset "sat_independentset" begin

    # Example 001: satisfiable 3-SAT
    x1 = BoolVar(:x1, false)
    nx1 = BoolVar(:x1, true)
    x2 = BoolVar(:x2, false)
    nx2 = BoolVar(:x2, true)
    x3 = BoolVar(:x3, false)
    nx3 = BoolVar(:x3, true)

    clause1 = CNFClause( [x1, nx2, x3] )
    clause2 = CNFClause( [nx1, x2, nx3] )
    clause3 = CNFClause( [x1, nx2, nx3] )
    clause4 = CNFClause( [nx1, x2, x3] )

    clause_lst = [clause1, clause2, clause3, clause4]
    sat01 = Satisfiability(CNF(clause_lst))

    reduction_results = reduceto(IndependentSet, sat01 )
    IS01 = reduction_results.is_target
    sol_IS = findbest( IS01, BruteForce() )
    @test Set( findbest(sat01, BruteForce()) ) == Set( extract_solution(reduction_results, sol_IS) )

    @test target_problem( reduction_results ) == IS01

    # Example 002: satisfiable 3-SAT
    clause5 = CNFClause( [nx1, x2, x3] )
    clause6 = CNFClause( [x1, nx2, x3] )
    clause7 = CNFClause( [x1, x2, nx3] )
    sat02 = Satisfiability( CNF([clause5, clause6, clause7]) )
    reduction_results_02 = reduceto(IndependentSet, sat02)
    IS02 = reduction_results_02.is_target
    sol_IS_02 = findbest( IS02, BruteForce() )
    @test Set( findbest( sat02, BruteForce() ) ) == Set( extract_solution(reduction_results_02, sol_IS_02) )

    # Example 003: satisfiable 3-SAT
    clause8 = CNFClause( [x1, x2, x3] )
    clause9 = CNFClause( [nx1, nx2, nx3] )
    sat03 = Satisfiability( CNF([clause8, clause9]) )
    reduction_results_03 = reduceto(IndependentSet, sat03)
    IS03 = reduction_results_03.is_target
    sol_IS_03 = findbest( IS03, BruteForce() )
    @test Set( findbest( sat03, BruteForce() ) ) == Set( extract_solution(reduction_results_03, sol_IS_03) )

    # Example 004: unsatisfiable 3-SAT (trivial example)
    clause10 = CNFClause( [x1, x1, x1] )
    clause11 = CNFClause( [nx1, nx1, nx1])
    sat04 = Satisfiability( CNF([clause10, clause11]) )
    reduction_results_04 = reduceto(IndependentSet, sat04)
    @test reduction_complexity(IndependentSet, sat04) == 1
    IS04 = reduction_results_04.is_target
    sol_IS_04 = findbest( IS04, BruteForce() )
    @test Set( findbest( sat04, BruteForce() ) ) == Set( extract_solution(reduction_results_04, sol_IS_04) )

    # Example 005: unsatisfiable 1-SAT (equivalent with example 004)
    sat05 = Satisfiability( CNF( [ CNFClause([x1]), CNFClause([nx1]) ] ) )
    reduction_results_05 = reduceto(IndependentSet, sat05)
    @test reduction_complexity(IndependentSet, sat05) == 1
    IS05 = reduction_results_05.is_target
    sol_IS_05 = findbest( IS05, BruteForce() )
    @test Set( findbest( sat05, BruteForce() ) ) == Set( extract_solution(reduction_results_05, sol_IS_05) )

    # Example 006: unsatisfiable 2-SAT
    sat06 = Satisfiability( CNF( [ CNFClause([x1, x2]), CNFClause([x1, nx2]), CNFClause([nx1, x2]), CNFClause([nx1, nx2]) ] ) )
    reduction_results_06 = reduceto(IndependentSet, sat06)
    @test reduction_complexity(IndependentSet, sat06) == 1
    IS06 = reduction_results_06.is_target
    sol_IS_06 = findbest( IS06, BruteForce() )
    @test Set( findbest( sat06, BruteForce() ) ) == Set( extract_solution(reduction_results_06, sol_IS_06) )

    # Example 007: satisfiable 2-SAT
    sat07 = Satisfiability( CNF( [ CNFClause([x1, x2]), CNFClause([x1, nx2]), CNFClause([nx1, x2]) ] ) )
    reduction_results_07 = reduceto(IndependentSet, sat07)
    @test reduction_complexity(IndependentSet, sat07) == 1
    IS07 = reduction_results_07.is_target
    sol_IS_07 = findbest( IS07, BruteForce() )
    @test Set( findbest( sat07, BruteForce() ) ) == Set( extract_solution(reduction_results_07, sol_IS_07) )
end