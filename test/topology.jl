using Test, ProblemReductions, Graphs
using Graphs: SimpleEdge
using ProblemReductions: HyperEdge

@testset "hyper graph" begin
    hg = HyperGraph(5, [[1, 2], [2, 3, 4]])
    @test ne(hg) == 2
    @test nv(hg) == 5
    @test edges(hg) == [HyperEdge([1, 2]), HyperEdge([2, 3, 4])]
    @test vertices(hg) == 1:5
    he = HyperEdge([2, 3, 4])
    @test ProblemReductions.num_vertices(he) == 3
    @test he == HyperEdge([2, 3, 4])
    @test ProblemReductions.contains(he, 2)
    @test !ProblemReductions.contains(he, 5)
    J = [1, 1]
    ProblemReductions._add_edge_weight!(hg, he, J, 5)
    @test edges(hg) == [HyperEdge([1, 2]), HyperEdge([2, 3, 4])]
    @test J == [1, 6]
    @test has_edge(hg, he)
    he = HyperEdge([2, 3, 5])
    ProblemReductions._add_edge_weight!(hg, he, J, 5)
    @test edges(hg) == [HyperEdge([1, 2]), HyperEdge([2, 3, 4]), HyperEdge([2, 3, 5])]
    @test J == [1, 6, 5]
end

@testset "unit-disk graph" begin
    udg = UnitDiskGraph([(0.0, 0.0), (1.0, 0.0), (0.0, 1.0), (1.0, 1.0)], 1.2)
    @test ne(udg) == 4
    @test nv(udg) == 4
    @test SimpleEdge(3, 4) in edges(udg)
    @test collect(edges(udg)) == [SimpleEdge(1, 2), SimpleEdge(1, 3), SimpleEdge(2, 4), SimpleEdge(3, 4)]
    @test vertices(udg) == 1:4
end

@testset "grid graph" begin
    gg = GridGraph(Bool[1 0; 1 1], 1.2)
    @test ne(gg) == 2
    @test nv(gg) == 3
    @test SimpleEdge(2, 3) in edges(gg)
    @test collect(edges(gg)) == [SimpleEdge(1, 2), SimpleEdge(2, 3)]
    @test vertices(gg) == 1:3

    grid = GridGraph((5, 5), [(2, 3), (2, 4), (5, 5)], 1.2)
    g = SimpleGraph(grid)
    @test ne(g) == 1
    @test vertices(grid) == vertices(g)
    @test neighbors(grid, 2) == neighbors(g, 2)

    grid = GridGraph((5, 5), [(2, 3), (2, 4), (5, 5)], 4.0)
    g = SimpleGraph(grid)
    @test ne(g) == 3
    @test vertices(grid) == vertices(g)
    @test neighbors(grid, 2) == neighbors(g, 2)

    ig, _ = induced_subgraph(grid, [1, 2])
    @test ne(ig) == 1
end
