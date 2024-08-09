using ProblemReductions, Test, Graphs

@testset "reduction path" begin
    g = reduction_graph()
    @test g isa ReductionGraph
    paths = reduction_paths(MaxCut, SpinGlass)
    @test length(paths) >= 1
    res = implement_reduction_path(g, paths[1], MaxCut(smallgraph(:petersen)))
    @test target_problem(res) isa SpinGlass
    @test reduction_complexity(res) == 1

    paths = reduction_paths(MaxCut, QUBO)
    @test length(paths) >= 1
    res = implement_reduction_path(g, paths[1], MaxCut(smallgraph(:petersen)))
    @test target_problem(res) isa QUBO
    @test reduction_complexity(res) == 1
end