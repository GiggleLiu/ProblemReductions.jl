using ProblemReductions, Test

@testset "circuit expr" begin
    ex = quote
        c = x ∧ y
        d = x ∨ c
    end
    circuit = ProblemReductions.analyse_circuit(ex)
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
end