using ProblemReductions, Test, Graphs

@testset "reduction path" begin
    g = reduction_graph()
    @test g isa ReductionGraph
    paths = reduction_paths(MaxCut, SpinGlass)
    @test length(paths) >= 1
    @test target_problem(implement_reduction_path(g, paths[1], MaxCut(smallgraph(:petersen)))) isa SpinGlass

    paths = reduction_paths(MaxCut, QUBO)
    @test length(paths) >= 1
    @test target_problem(implement_reduction_path(g, paths[1], MaxCut(smallgraph(:petersen)))) isa QUBO
end