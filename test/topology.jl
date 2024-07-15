using Test, ProblemReductions, Graphs
using Graphs: SimpleEdge

@testset "hyper graph" begin
    hg = HyperGraph(5, [[1, 2], [2, 3, 4]])
    @test ne(hg) == 2
    @test nv(hg) == 5
    @test edges(hg) == [[1, 2], [2, 3, 4]]
    @test vertices(hg) == 1:5
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
end