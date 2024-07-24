using Test, ProblemReductions, Graphs
using ProblemReductions: maxcut2spinglass

# add a simple test to check the reduction process
@testset "spinglass_maxcut" begin
    # construct a graph
    g = SimpleGraph(4)
    add_edge!(g, 1, 2) 
    add_edge!(g, 1, 3)
    add_edge!(g, 3, 4)
    add_edge!(g, 2, 3)

    mc = MaxCut(g, [1, 3, 1, 4])
    Base.:(==)(a::ReductionMaxCutToSpinGlass, b::ReductionMaxCutToSpinGlass) = a.spinglass == b.spinglass
    @test reduceto(SpinGlass, mc) == ReductionMaxCutToSpinGlass(maxcut2spinglass(mc))
    @test maxcut2spinglass(mc) == SpinGlass(g, [1, 3, 1, 4])
    @test findbest(mc, BruteForce()) == [[0, 0, 1, 0], [0, 1, 1, 0], [1, 0, 0, 1], [1, 1, 0, 1]] # in lexicographic order
    @test findbest(maxcut2spinglass(mc), BruteForce()) == [[0, 0, 1, 0], [0, 1, 1, 0], [1, 0, 0, 1], [1, 1, 0, 1]] # in lexicographic order
end