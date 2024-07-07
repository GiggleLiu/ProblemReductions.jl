using Test, ProblemReductions
import GenericTensorNetworks
using ProblemReductions: SGGadget, spinglass_gadget, SpinGlass

function ground_states(sg::SpinGlass)
    sg = GenericTensorNetworks.SpinGlass(sg.graph.n, sg.graph.edges, sg.weights)
    return GenericTensorNetworks.solve(GenericTensorNetworks.GenericTensorNetwork(sg), GenericTensorNetworks.ConfigsMin())[]
end

function truth_table(ga::SGGadget)
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

@testset "gates" begin
    res = ground_states(spinglass_gadget(:∧).sg)
    @test collect.(sort(res.c.data)) == collect.(map(x->StaticElementVector(2, x), [[0, 0, 0], [0, 1, 0], [1, 0, 0], [1, 1, 1]]))
    tt = truth_table(spinglass_gadget(:∧))
    @test length(tt) == 4
    @test tt[[0, 0]] == tt[[0, 1]] == tt[[1, 0]] == [0]
    @test tt[[1, 1]] == [1]

    res = ground_states(spinglass_gadget(:∨).sg)
    @test collect.(sort(res.c.data)) == collect.(map(x->StaticElementVector(2, x), [[0, 0, 0], [0, 1, 1], [1, 0, 1], [1, 1, 1]]))

    res = ground_states(spinglass_gadget(:¬).sg)
    @test collect.(sort(res.c.data)) == collect.(map(x->StaticElementVector(2, x), [[0, 1], [1, 0]]))
end

@testset "arraymul" begin
    arr = spinglass_gadget(:arraymul)
    tt = truth_table(arr)
    @test length(tt) == 16
    @test tt[[0, 0, 0, 0]] == tt[[1, 0, 0, 0]] == tt[[0, 1, 0, 0]] == [0, 0]
    @test tt[[0, 0, 1, 0]] == tt[[1, 0, 1, 0]] == tt[[0, 1, 1, 0]] == tt[[1, 1, 0, 0]] ==
        tt[[0, 0, 0, 1]] == tt[[1, 0, 0, 1]] == tt[[0, 1, 0, 1]]  == [0, 1]
    @test tt[[1, 1, 1, 0]] == tt[[1, 1, 0, 1]] ==
        tt[[1, 0, 1, 1]] == tt[[0, 1, 1, 1]] == tt[[0, 0, 1, 1]] == [1, 0]
    @test tt[[1, 1, 1, 1]] == [1, 1]
end

@testset "arraymul compose" begin
    arr = ProblemReductions.compose_multiplier(2, 2)
    @test arr.sg.n == 20
    tt = truth_table(arr)
    @test length(tt) == 16
    ProblemReductions.set_input!(arr, [0, 1, 0, 1])  # 2 x 2 == 4
    @test truth_table(arr) == Dict([0, 1, 0, 1] => [0, 0, 1, 0])
end

@testset "compose circuit" begin
    a, b, c, d, e = ProblemReductions.booleans(5)
    expr = (a ∧ ¬b)
    gadget, variables = ProblemReductions.compose_circuit(expr)
    @show truth_table(gadget)

    expr = (a ∧ b) ∨ (c ∧ ¬e)
    gadget, variables = ProblemReductions.compose_circuit(expr)
    @show truth_table(gadget)
end