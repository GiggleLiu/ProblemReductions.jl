using Test, ProblemReductions

@testset "multiplier" begin
    s, c, p, q, spre, cpre = BooleanExpr.([:s, :c, :p, :q, :spre, :cpre])
    exprs, ancillas = ProblemReductions.multiplier(s, c, p, q, spre, cpre)
    @test length(ancillas) == 4
    @test length(exprs) == 6
    circ = Circuit(exprs)
    for p in [true, false], q in [true, false], spre in [true, false], cpre in [true, false]
        assignment = Dict(:p => p, :q => q, :spre => spre, :cpre => cpre)
        res = energy(circ, assignment)
        @test res[:s] + 2 * res[:c] == (p * q) + spre + cpre
    end
end

@testset "reduction" begin
    fact = Factoring(1, 1, 1)
    res = reduceto(CircuitSAT, fact)
    best_configs = findbest(target_problem(res), BruteForce())
    @test length(best_configs) == 1
    best_config = best_configs[1]
    assignment = Dict(zip(res.circuit.symbols, best_config))
    @test assignment[:p1] * assignment[:q1] ==1

    fact2 = Factoring(2, 1, 2)
    res2 = reduceto(CircuitSAT, fact2)
    best_configs2 = findbest(target_problem(res2), BruteForce())
    @test length(best_configs2) == 1
    best_config2 = best_configs2[1]
    assignment2 = Dict(zip(res2.circuit.symbols, best_config2))
    @test (2* assignment2[:p2]+ assignment2[:p1]) * assignment2[:q1] == 2

    fact3 = Factoring(2, 1, 3)
    res3 = reduceto(CircuitSAT, fact3)
    best_configs3 = findbest(target_problem(res3), BruteForce())
    @test length(best_configs3) == 1
    best_config3 = best_configs3[1]
    assignment3 = Dict(zip(res3.circuit.symbols, best_config3))
    @test (2* assignment3[:p2]+ assignment3[:p1]) * assignment3[:q1] == 3
end