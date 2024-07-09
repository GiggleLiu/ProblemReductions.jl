using Test, ProblemReductions
using ProblemReductions: SGGadget, spinglass_gadget, SpinGlass, truth_table
using ProblemReductions.BitBasis

@testset "gates" begin
    res = findbest(spinglass_gadget(:∧).sg, BruteForce())
    @test collect.(sort(res)) == [[0, 0, 0], [0, 1, 0], [1, 0, 0], [1, 1, 1]]
    tt = truth_table(spinglass_gadget(:∧))
    @test length(tt) == 4
    @test tt[bit"00"] == tt[bit"01"] == tt[bit"10"] == bit"0"
    @test tt[bit"11"] == bit"1"

    res = findbest(spinglass_gadget(:∨).sg, BruteForce())
    @test collect.(sort(res)) == [[0, 0, 0], [0, 1, 1], [1, 0, 1], [1, 1, 1]]

    res = findbest(spinglass_gadget(:¬).sg, BruteForce())
    @test collect.(sort(res)) == [[0, 1], [1, 0]]
end

@testset "arraymul" begin
    arr = spinglass_gadget(:arraymul)
    tt = truth_table(arr)
    @test length(tt) == 16
    @test tt[bit"0000"] == tt[bit"0001"] == tt[bit"0010"] == bit"00"
    @test tt[bit"0100"] == tt[bit"0101"] == tt[bit"0110"] == tt[bit"0011"] ==
        tt[bit"1000"] == tt[bit"1001"] == tt[bit"1010"]  == bit"10"
    @test tt[bit"0111"] == tt[bit"1011"] ==
        tt[bit"1101"] == tt[bit"1110"] == tt[bit"1100"] == bit"01"
    @test tt[bit"1111"] == bit"11"
end

@testset "arraymul compose" begin
    arr = ProblemReductions.compose_multiplier(2, 2)
    @test num_variables(arr.sg) == 20
    tt = truth_table(arr)
    @test length(tt) == 16
    ProblemReductions.set_input!(arr, [0, 1, 0, 1])  # 2 x 2 == 4
    res = findbest(arr.sg, BruteForce())
    @test ProblemReductions.infer_logic(res, arr.inputs, arr.outputs) == Dict([0, 1, 0, 1] => [0, 0, 1, 0])
end

@testset "compose circuit" begin
    a, b, c, d, e = ProblemReductions.booleans(5)
    expr = (a ∧ ¬b)
    gadget, variables = ProblemReductions.expr_to_spinglass_gadget(expr)
    tb = truth_table(gadget; variables)
    @test tb[bit"00"] == bit"0"
    @test tb[bit"01"] == bit"1"
    @test tb[bit"10"] == bit"0"
    @test tb[bit"11"] == bit"0"

    expr = (a ∧ b) ∨ (c ∧ ¬e)
    gadget, variables = ProblemReductions.expr_to_spinglass_gadget(expr)
    tb = truth_table(gadget; variables)
    @test tb.inputs == [a.var, b.var, c.var, e.var]
    @test tb[bit"0000"] == bit"0"
    @test tb[bit"0001"] == bit"0"
    @test tb[bit"0010"] == bit"0"
    @test tb[bit"0011"] == bit"1"
    @test tb[bit"0100"] == bit"1"
    @test tb[bit"0101"] == bit"1"
    @test tb[bit"0110"] == bit"1"
    @test tb[bit"0111"] == bit"1"
    @test tb[bit"1000"] == bit"0"
    @test tb[bit"1001"] == bit"0"
    @test tb[bit"1010"] == bit"0"
    @test tb[bit"1011"] == bit"1"
    @test tb[bit"1100"] == bit"0"
    @test tb[bit"1101"] == bit"0"
    @test tb[bit"1110"] == bit"0"
    @test tb[bit"1111"] == bit"1"
end

@testset "spinglass circuit" begin
    circuit = @circuit begin
        c = x ∧ y
        d = x ∨ (c ∧ ¬z)
    end
    sg, variables = ProblemReductions.circuit2spinglass(circuit)
    indexof(x) = findfirst(==(x), variables)
    gadget = SGGadget(sg, indexof.([:x, :y, :z]), [indexof(:d)])
    tb = truth_table(gadget; variables)
    @test tb.values == vec([(x & y & (1-z)) | x for x in [0, 1], y in [0, 1], z in [0, 1]])
end