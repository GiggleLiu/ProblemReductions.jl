using Test, ProblemReductions

@testset "multiplier" begin
    s, c, p, q, spre, cpre = BooleanExpr.([:s, :c, :p, :q, :spre, :cpre])
    exprs, ancillas = ProblemReductions.multiplier(s, c, p, q, spre, cpre)
    @test length(ancillas) == 4
    @test length(exprs) == 6
    circ = Circuit(exprs)
    for p in [true, false], q in [true, false], spre in [true, false], cpre in [true, false]
        assignment = Dict(:p => p, :q => q, :spre => spre, :cpre => cpre)
        res = evaluate(circ, assignment)
        @test res[:s] + 2 * res[:c] == (p * q) + spre + cpre
    end
end

@testset "reduction" begin
    fact = Factoring(1, 1, 1)
    res = reduceto(CircuitSAT, fact)
    best_configs = findbest(target_problem(res), BruteForce())
    @show best_configs
    @test length(best_configs) == 1
    best_config = best_configs[1]
    assignment = Dict(zip(res.circuit.symbols, best_config))
    @show assignment
    @show assignment[:p1], assignment[:q1]
    @test assignment[:p1] * assignment[:q1] ==1
end