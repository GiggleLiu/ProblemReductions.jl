using Test, ProblemReductions, Graphs

@testset "sat_independentset" begin

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
end