using Test, ProblemReductions

@testset "sat_3sat" begin
    # Benchmark CNF
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
    @test generate_dummy_var(5) == BoolVar(Symbol("z_$(6)"), false)
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

    reduction_result = reduceto(Satisfiability, sat01)
    @test reduction_result.sat_target == Satisfiability( transform_to_3_literal_cnf( rename_variables(sat01)[1] ).cnf )
    @test target_problem( reduction_result ) == Satisfiability( transform_to_3_literal_cnf( rename_variables(sat01)[1] ).cnf )

    original_sol = findbest(sat01, BruteForce() )
    new_sol = findbest(reduction_result.sat_target, BruteForce() )
    @test original_sol == extract_solution(reduction_result, new_sol)
end