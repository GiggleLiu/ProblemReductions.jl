using ProblemReductions, Test

@testset "clauses" begin
    a, b, c, d, e = booleans(5)
    @test a isa BooleanExpr
    @test a.head == :var
    @test a.var == Symbol(1)
    nota = ¬a
    @test is_literal(a)
    @test is_literal(¬a)
    @test nota isa BooleanExpr
    @test nota.head == :¬
    @test nota.args[1] == a

    clause = ∧(∨(¬a, b), ∨(c, ¬e))
    @test is_cnf(clause)
    clause = ∨(∧(a, b), ∧(c, ¬e))
    @test is_dnf(clause)
end

@testset "hash, eval" begin
    a, b, c, d, e = booleans(5)
    expr = (a ∧ b) ∨ (c ∧ ¬e)
    d = Dict(a=>true, b=>true, c=>true, e=>false)
    @test ProblemReductions.evaluate_expr(a, d)  == true
    @test d[a] == true
    @test ProblemReductions.evaluate_expr(expr, d) == true
end
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
    @test ProblemReductions.evaluate_expr(circuit, Dict(:x => true, :y => false)) == Dict(:x => true, :y => false, :c => false, :d => true)
    circuit = @circuit begin
        c = x ∧ y
        d = x ∨ (c ∧ ¬z)
    end
    println(circuit)
    @test ProblemReductions.evaluate_expr(circuit, Dict(:x => true, :y => false, :z => false)) == Dict(:x => true, :y => false, :z => false, :c => false, :d => true)
    ssa = ProblemReductions.simple_form(circuit)
    res = ProblemReductions.evaluate_expr(ssa, Dict(:x => true, :y => false, :z => false))
    @test res[:x] && !res[:y] && !res[:z] && !res[:c] && res[:d]
end

@testset "properties" begin
    circuit = @circuit begin
        c = x ∧ y
        d = x ∨ (c ∧ ¬z)
    end
    sat = CircuitSAT(circuit)
    @test problem_size(sat) == (; num_exprs = 4, num_variables = 7)
    println(sat)
    @test sat.symbols[[1, 2, 3, 5, 7]] == [:c, :x, :y, :z, :d]
    @test variables(sat) == collect(1:7)
    @test num_variables(sat) == 7
    solution = solution_size(sat, [true, false, false, true, false, true, false])
    @test solution.size == 2
    @test solution.is_valid
                       # c    x      y      ¬z     z    c ∧ ¬z   d
    # c = x ∧ y - 1
    # m1 = ¬z - 0
    # m2 = c ∧ m1 - 0
    # d = x ∨ m2 - 1
    solution = solution_size(sat, [false, false, false, true, false, false, false])
    @test solution.is_valid
    @test solution.size == 0
end

@testset "local_solution_spec" begin
    circuit = @circuit begin
        c = x ∧ y
    end
    push!(circuit.exprs, Assignment([:c],BooleanExpr(true)))
    sat = CircuitSAT(circuit)
    ans = ProblemReductions.local_solution_spec(sat)
    @test ans[1].variables == [1,2,3]
    @test ans[2].variables == [1]
end