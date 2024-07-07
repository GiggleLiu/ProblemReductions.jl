using Test, ProblemReductions
import GenericTensorNetworks
using ProblemReductions: SGGadget, spinglass_gadget, SpinGlass

function ground_states(sg::SpinGlass)
    sg = GenericTensorNetworks.SpinGlass(sg.graph.n, sg.graph.edges, sg.weights)
    return GenericTensorNetworks.solve(GenericTensorNetworks.GenericTensorNetwork(sg), GenericTensorNetworks.ConfigsMin())[]
end

function infer_logic(ga::SGGadget)
    res = ground_states(ga.sg)
    output = Dict{Vector{Int}, Vector{Int}}()
    for c in res.c.data
        key = c[ga.inputs]
        if haskey(output, key)
            @assert output[key] == max(output[key], c[ga.outputs])
        else
            output[key] = c[ga.outputs]
        end
    end
    return output
end
function truth_table(ga::SGGadget; variables=1:nspin(ga.sg))
    return dict2table(variables[ga.inputs], variables[ga.outputs], infer_logic(ga))
end
function dict2table(inputs, outputs, d::Dict{Vector{Int}, Vector{Int}})
    ni, no = length(inputs), length(outputs)
    @assert length(d) == 2^ni
    return TruthTable(inputs, outputs, [BitStr(d[[readbit(k, i) for i=1:ni]]) for k in 0:length(d)-1])
end

@testset "gates" begin
    res = ground_states(spinglass_gadget(:∧).sg)
    @test collect.(sort(res.c.data)) == collect.(map(x->StaticElementVector(2, x), [[0, 0, 0], [0, 1, 0], [1, 0, 0], [1, 1, 1]]))
    tt = truth_table(spinglass_gadget(:∧))
    @test length(tt) == 4
    @test tt[bit"00"] == tt[bit"01"] == tt[bit"10"] == bit"0"
    @test tt[bit"11"] == bit"1"

    res = ground_states(spinglass_gadget(:∨).sg)
    @test collect.(sort(res.c.data)) == collect.(map(x->StaticElementVector(2, x), [[0, 0, 0], [0, 1, 1], [1, 0, 1], [1, 1, 1]]))

    res = ground_states(spinglass_gadget(:¬).sg)
    @test collect.(sort(res.c.data)) == collect.(map(x->StaticElementVector(2, x), [[0, 1], [1, 0]]))
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
    @test arr.sg.n == 20
    tt = truth_table(arr)
    @test length(tt) == 16
    ProblemReductions.set_input!(arr, [0, 1, 0, 1])  # 2 x 2 == 4
    @test infer_logic(arr) == Dict([0, 1, 0, 1] => [0, 0, 1, 0])
end

@testset "compose circuit" begin
    a, b, c, d, e = ProblemReductions.booleans(5)
    expr = (a ∧ ¬b)
    gadget, variables = ProblemReductions.compose_circuit(expr)
    tb = truth_table(gadget; variables)
    @test tb[bit"00"] == bit"0"
    @test tb[bit"01"] == bit"1"
    @test tb[bit"10"] == bit"0"
    @test tb[bit"11"] == bit"0"

    expr = (a ∧ b) ∨ (c ∧ ¬e)
    gadget, variables = ProblemReductions.compose_circuit(expr)
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