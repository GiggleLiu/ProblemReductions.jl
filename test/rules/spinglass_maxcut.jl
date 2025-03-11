using Test, ProblemReductions, Graphs

@testset "maxut -> spinglass" begin
    # construct a graph
    g = SimpleGraph(4)
    add_edge!(g, 1, 2) 
    add_edge!(g, 1, 3)
    add_edge!(g, 3, 4)
    add_edge!(g, 2, 3)

    mc = MaxCut(g, [1, 3, 1, 4])
    Base.:(==)(a::ReductionMaxCutToSpinGlass, b::ReductionMaxCutToSpinGlass) = a.spinglass == b.spinglass
    res = reduceto(SpinGlass{<:SimpleGraph}, mc)
    @test target_problem(res) == res.spinglass
    @test reduceto(SpinGlass{<:SimpleGraph}, mc) == res
    @test reduceto(SpinGlass{<:SimpleGraph}, mc).spinglass == SpinGlass(g, [1, 3, 1, 4], zeros(Int, 4))
    @test findbest(mc, BruteForce()) == [[0, 0, 1, 0], [0, 1, 1, 0], [1, 0, 0, 1], [1, 1, 0, 1]] # in lexicographic order
    @test sort(findbest(target_problem(reduceto(SpinGlass{<:SimpleGraph}, mc)), BruteForce())) == sort([[0, 0, 1, 0], [0, 1, 1, 0], [1, 0, 0, 1], [1, 1, 0, 1]]) # in lexicographic order
end

@testset "spinglass -> maxcut" begin
    g1 = SimpleGraph(4)
    for (i, j) in [(1, 2), (1, 3), (3, 4), (2, 3)]
        add_edge!(g1, i, j)
    end
    sg = SpinGlass(g1, [1, 3, 1, 4], zeros(Int, 4))
    mcr = reduceto(MaxCut, sg)
    res = ReductionSpinGlassToMaxCut(mcr.maxcut, mcr.ancilla)
    @test mcr.maxcut == MaxCut(g1, [1, 3, 1, 4])
    @test target_problem(res) == res.maxcut
    @test reduceto(MaxCut, sg) == res
    @test reduceto(MaxCut, sg) == ReductionSpinGlassToMaxCut(MaxCut(g1, [1, 3, 1, 4]),0)
    @test findbest(sg, BruteForce()) == [[0, 0, 1, 0], [0, 1, 1, 0], [1, 0, 0, 1], [1, 1, 0, 1]] # in lexicographic order
    @test findbest(res.maxcut, BruteForce()) == [[0, 0, 1, 0], [0, 1, 1, 0], [1, 0, 0, 1], [1, 1, 0, 1]] # in lexicographic order

    gadget = spinglass_gadget(Val{:⊻}())
    res = reduceto(MaxCut, gadget.problem)
    best_maxcut = findbest(res.maxcut, BruteForce())
    @test length(best_maxcut) == 8
    best = unique(extract_solution.(Ref(res), best_maxcut))
    @test sort(best) == sort(findbest(gadget.problem, BruteForce()))
end
