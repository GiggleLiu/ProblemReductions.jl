using Test, ProblemReductions
import GenericTensorNetworks
using ProblemReductions: SGGadget, sg_gadget_and, sg_gadget_or, sg_gadget_not, sg_gadget_arraymul, SpinGlass

function ground_states(sg::SpinGlass)
    sg = GenericTensorNetworks.SpinGlass(sg.n, sg.cliques, sg.weights)
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
    res = ground_states(sg_gadget_and().sg)
    @test collect.(sort(res.c.data)) == collect.(map(x->StaticElementVector(2, x), [[0, 0, 0], [0, 1, 0], [1, 0, 0], [1, 1, 1]]))
    tt = truth_table(sg_gadget_and())
    @test length(tt) == 4
    @test tt[[0, 0]] == tt[[0, 1]] == tt[[1, 0]] == [0]
    @test tt[[1, 1]] == [1]

    res = ground_states(sg_gadget_or().sg)
    @test collect.(sort(res.c.data)) == collect.(map(x->StaticElementVector(2, x), [[0, 0, 0], [0, 1, 1], [1, 0, 1], [1, 1, 1]]))

    res = ground_states(sg_gadget_not().sg)
    @test collect.(sort(res.c.data)) == collect.(map(x->StaticElementVector(2, x), [[0, 1], [1, 0]]))
end

@testset "arraymul" begin
    arr = sg_gadget_arraymul()
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
