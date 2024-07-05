using ProblemReductions, Test
using ProblemReductions: BooleanExpr, booleans, is_literal, is_cnf, is_dnf

@testset "clauses" begin
    a, b, c, d, e = booleans(5)
    @test a isa BooleanExpr
    @test a.head == :var
    @test a.var == 1
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