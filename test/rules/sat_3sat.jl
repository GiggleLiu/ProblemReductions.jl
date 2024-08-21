using Test, ProblemReductions
using ProblemReductions: generate_dummy_var, rename_variables, transform_to_3_literal_clause, transform_to_3_literal_cnf

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

    @test variables( rename_variables(sat01)[1] ) == [Symbol("x_1"), Symbol("x_2"), Symbol("x_3"), Symbol("x_4")]
    @test generate_dummy_var(5)[1] == BoolVar(Symbol("z_$(6)"), false)
    @test CNF( transform_to_3_literal_clause(clause2.vars, 0)[1] ) == ( bv2 ∨ bv3 ∨ BoolVar(Symbol("z_$(1)"), false) ) ∧ ( bv2 ∨ bv3 ∨ BoolVar(Symbol("z_$(1)"), true) )

    expected_transformed_cnf = CNF([
    CNFClause([bv1, BoolVar(Symbol("z_1"), false), BoolVar(Symbol("z_2"), false)]),
    CNFClause([bv1, BoolVar(Symbol("z_1"), true), BoolVar(Symbol("z_2"), false)]),
    CNFClause([bv1, BoolVar(Symbol("z_1"), false), BoolVar(Symbol("z_2"), true)]),
    CNFClause([bv1, BoolVar(Symbol("z_1"), true), BoolVar(Symbol("z_2"), true)]),

    CNFClause([bv2, bv3, BoolVar(Symbol("z_3"), false)]),
    CNFClause([bv2, bv3, BoolVar(Symbol("z_3"), true)]),

    CNFClause([bv1, bv2, BoolVar(Symbol("z_4"), false)]),
    CNFClause([bv3, bv4, BoolVar(Symbol("z_4"), true)])
    ])
    transformed_cnf = transform_to_3_literal_cnf(sat01).cnf
    @test transformed_cnf == expected_transformed_cnf

    reduction_result = reduceto(KSatisfiability, sat01)
    @test reduction_result.sat_target == KSatisfiability{3}( transform_to_3_literal_cnf( rename_variables(sat01)[1] ).cnf )
    @test target_problem( reduction_result ) == KSatisfiability{3}( transform_to_3_literal_cnf( rename_variables(sat01)[1] ).cnf )

    original_sol = findbest(sat01, BruteForce() )
    new_sol = findbest(reduction_result.sat_target, BruteForce() )
    @test original_sol == extract_multiple_solutions(reduction_result, new_sol)
    @test issubset(original_sol, extract_solution.(Ref(reduction_result), new_sol) )
    @test reduction_complexity(KSatisfiability, sat01) == 1

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

    reduction_result_03 = reduceto(KSatisfiability, sat02)
    @test Set( findbest(sat02, BruteForce() ) ) == Set( extract_multiple_solutions( reduction_result_03, findbest(reduction_result_03.sat_target, BruteForce() ) ) )
    @test issubset( Set( findbest(sat02, BruteForce() ) ), Set( unique( extract_solution.( Ref(reduction_result_03), findbest(reduction_result_03.sat_target, BruteForce() ) ) ) ) )
end
    

    
