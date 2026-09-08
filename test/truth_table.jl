using ProblemReductions, Test, ProblemReductions.BitBasis

@testset "truth_table" begin
    tb = TruthTable(['a', 'b'], ['c'], [bit"1", bit"1", bit"0", bit"1"])
    print(tb)
    @test tb[bit"00"] == bit"1"
    @test tb[bit"01"] == bit"1"
    @test tb[bit"10"] == bit"0"
    @test tb[bit"11"] == bit"1"
end
@testset "constraint and objective table display" begin
    con = ProblemReductions.LocalConstraint(2, [1], [false, true])
    obj = ProblemReductions.LocalSolutionSize(2, [1], [0, 1])
    @test occursin("Configuration", sprint(show, con))
    @test occursin("Valid", sprint(show, con))
    @test occursin("Configuration", sprint(show, obj))
    @test occursin("Size", sprint(show, obj))
end
