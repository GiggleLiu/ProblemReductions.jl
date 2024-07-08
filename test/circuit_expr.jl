using ProblemReductions, Test

@testset "circuit expr" begin
    ex = quote
        c = x ∧ y
        d = x ∨ c
    end
    circuit = ProblemReductions.render_circuit(ex)
    println(circuit)
    circuit = @circuit begin
        c = x ∧ y
        d = x ∨ c
    end
    println(circuit)
    @test ProblemReductions.evaluate(circuit, Dict(:x => true, :y => false)) == Dict(:x => true, :y => false, :c => false, :d => true)
    circuit = @circuit begin
        c = x ∧ y
        d = x ∨ (c ∧ ¬z)
    end
    println(circuit)
    @test ProblemReductions.evaluate(circuit, Dict(:x => true, :y => false, :z => false)) == Dict(:x => true, :y => false, :z => false, :c => false, :d => true)
    ssa = ProblemReductions.ssa_form(circuit)
    res = ProblemReductions.evaluate(ssa, Dict(:x => true, :y => false, :z => false))
    @test res[:x] && !res[:y] && !res[:z] && !res[:c] && res[:d]
end