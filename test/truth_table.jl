using ProblemReductions, Test, ProblemReductions.BitBasis

@testset "truth_table" begin
    tb = TruthTable(['a', 'b'], ['c'], [bit"1", bit"1", bit"0", bit"1"])
    print(tb)
    @test tb[bit"00"] == bit"1"
    @test tb[bit"01"] == bit"1"
    @test tb[bit"10"] == bit"0"
    @test tb[bit"11"] == bit"1"
end