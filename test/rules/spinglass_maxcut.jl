using Test, ProblemReductions, Graphs
using ProblemReductions: maxcut2spinglass, spinglass2maxcut, ReductionMaxCutToSpinGlass, ReductionSpinGlassToMaxCut,vedges

@testset "maxut -> spinglass" begin
    # construct a graph
    g = SimpleGraph(4)
    add_edge!(g, 1, 2) 
    add_edge!(g, 1, 3)
    add_edge!(g, 3, 4)
    add_edge!(g, 2, 3)

    mc = MaxCut(g, [1, 3, 1, 4])
    Base.:(==)(a::ReductionMaxCutToSpinGlass, b::ReductionMaxCutToSpinGlass) = a.spinglass == b.spinglass
    res = ReductionMaxCutToSpinGlass(maxcut2spinglass(mc))
    @test target_problem(res) == res.spinglass
    @test reduceto(SpinGlass, mc) == res
    @test maxcut2spinglass(mc) == SpinGlass(g, [1, 3, 1, 4])
    @test findbest(mc, BruteForce()) == [[0, 0, 1, 0], [0, 1, 1, 0], [1, 0, 0, 1], [1, 1, 0, 1]] # in lexicographic order
    @test findbest(maxcut2spinglass(mc), BruteForce()) == [[0, 0, 1, 0], [0, 1, 1, 0], [1, 0, 0, 1], [1, 1, 0, 1]] # in lexicographic order
end

@testset "spinglass -> maxcut" begin
    g1 = SimpleGraph(4)
    for (i, j) in [(1, 2), (1, 3), (3, 4), (2, 3)]
        add_edge!(g1, i, j)
    end
    sg = SpinGlass(g1, [1, 3, 1, 4])
    mc,anc= spinglass2maxcut(sg)
    res = ReductionSpinGlassToMaxCut(mc, anc)
    @test mc == MaxCut(g1, [1, 3, 1, 4])
    @test target_problem(res) == res.maxcut
    @test reduceto(MaxCut, sg) == res
    @test spinglass2maxcut(sg) == (MaxCut(g1, [1, 3, 1, 4]),0)
    @test findbest(sg, BruteForce()) == [[0, 0, 1, 0], [0, 1, 1, 0], [1, 0, 0, 1], [1, 1, 0, 1]] # in lexicographic order
    @test findbest(res.maxcut, BruteForce()) == [[0, 0, 1, 0], [0, 1, 1, 0], [1, 0, 0, 1], [1, 1, 0, 1]] # in lexicographic order

    # hyper graph
    g2 = HyperGraph(3, [[1, 2], [1], [2,3], [2]])
    sg = SpinGlass(g2, [1, 2, 1, -1])
    mc,ancilla= spinglass2maxcut(sg) 
    expected_g = SimpleGraph(4)
    for (i, j) in [(1, 2), (1, 4), (2, 3), (2, 4)]
        add_edge!(expected_g, i, j)
    end
    res = ReductionSpinGlassToMaxCut(mc,ancilla)
    @test mc == MaxCut(expected_g, [1, 2, 1, -1])
    @test reduceto(MaxCut, sg) == res
    @test target_problem(res) == mc
    @test spinglass2maxcut(sg) == (mc,4)
    @test findbest(sg, BruteForce()) == [[1,0,1]]
    @test findbest(res.maxcut, BruteForce()) == [[1, 0, 1, 0], [0, 1, 0, 1]]
end
