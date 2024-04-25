using ProblemReductions, Test

@testset "clauses" begin
    a, b, c, d, e = booleans(5)
    @test typeof(a.mask) == StaticBitVector{5, 1}
    @test collect(a.mask) == [1, 0, 0, 0, 0]
    @test collect(d.val) == [0, 0, 0, 1, 0]
    nota = ¬a
    @test collect(nota.mask) == [1, 0, 0, 0, 0]
    @test collect(nota.val) == [0, 0, 0, 0, 0]
    clause = (¬a ∧ b ∧ c ∧ ¬e)
    @test collect(clause.mask) == [1, 1, 1, 0, 1]
    @test collect(clause.val) == [0, 1, 1, 0, 0]
    clause = ¬(¬a ∧ b ∧ c ∧ ¬e)
    @test collect(clause.mask) == [1, 1, 1, 0, 1]
    @test collect(clause.val) == [0, 1, 1, 0, 0]
end