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

@testset "properties" begin
    circuit = @circuit begin
        c = x ∧ y
        d = x ∨ (c ∧ ¬z)
    end
    sat = CircuitSAT(circuit)
    @test sat.symbols[[1, 2, 3, 5, 7]] == [:c, :x, :y, :z, :d]
    @test variables(sat) == collect(1:7)
    @test num_variables(sat) == 7
    @test terms(sat) == [[1, 2, 3], [4, 5], [6, 1, 4], [7, 2, 6]]
    @test evaluate(sat, [true, false, false, true, false, true, false]) == 1
                          # c    x      y      ¬z     z    c ∧ ¬z   d
    @test evaluate(sat, [false, false, false, true, false, false, false]) == 0
end