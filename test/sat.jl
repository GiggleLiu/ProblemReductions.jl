using ProblemReductions, Test
using ProblemReductions: BooleanExpr, booleans

@testset "clauses" begin
    a, b, c, d, e = booleans(5)
    @test a isa BooleanExpr
    @test a.head == :var
    @test a.var == 1
    nota = ¬a
    @test nota isa BooleanExpr
    @test nota.head == :¬
    @test nota.args[1] == a

    clause = (¬a ∧ b ∧ c ∧ ¬e)
    @test clause.head == :∧
    clause = ¬(¬a ∧ b ∧ c ∧ ¬e)
    @test clause.head == :¬
end