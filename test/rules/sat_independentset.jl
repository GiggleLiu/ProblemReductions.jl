using Test, ProblemReductions, Graphs

@testset "sat_independentset" begin

# Example 001
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

clauses = [clause1, clause2, clause3, clause4]
sat01 = Satisfiability(CNF(clauses))

reduction_results = reduceto(IndependentSet, sat01 )
IS01 = reduction_results.is_target
sol_IS = findbest( IS01, BruteForce() )
@test Set( findbest(sat01, BruteForce()) ) == Set( extract_solution(reduction_results, sol_IS) )

@test target_problem( reduction_results ) == IS01

# Example 002
clause5 = CNFClause( [nx1, x2, x3] )
clause6 = CNFClause( [x1, nx2, x3] )
clause7 = CNFClause( [x1, x2, nx3] )
sat02 = Satisfiability( CNF([clause5, clause6, clause7]) )
reduction_results_02 = reduceto(IndependentSet, sat02)
IS02 = reduction_results_02.is_target
sol_IS_02 = findbest( IS02, BruteForce() )
@test Set( findbest( sat02, BruteForce() ) ) == Set( extract_solution(reduction_results_02, sol_IS_02) )

# Example 003
clause8 = CNFClause( [x1, x2, x3] )
clause9 = CNFClause( [nx1, nx2, nx3] )
sat03 = Satisfiability( CNF([clause8, clause9]) )
reduction_results_03 = reduceto(IndependentSet, sat03)
IS03 = reduction_results_03.is_target
sol_IS_03 = findbest( IS03, BruteForce() )
@test Set( findbest( sat03, BruteForce() ) ) == Set( extract_solution(reduction_results_03, sol_IS_03) )

# Example 004
clause10 = CNFClause( [x1, x1, x1] )
clause11 = CNFClause( [nx1, nx1, nx1])
sat04 = Satisfiability( CNF([clause10, clause11]) )
reduction_results_04 = reduceto(IndependentSet, sat04)
IS04 = reduction_results_04.is_target
sol_IS_04 = findbest( IS04, BruteForce() )
@test extract_solution(reduction_results_04, sol_IS_04) == Vector{Int64}()

end