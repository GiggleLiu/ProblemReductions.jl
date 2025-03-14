using ProblemReductions, Test, Graphs

@testset "reduction path" begin
    g = reduction_graph()
    @test g isa ReductionGraph
    paths = reduction_paths(MaxCut, SpinGlass)
    @test length(paths) >= 1
    res = reduceto(paths[1], MaxCut(smallgraph(:petersen)))
    @test target_problem(res) isa SpinGlass

    paths = reduction_paths(MaxCut, QUBO)
    @test length(paths) >= 1
    source = MaxCut(smallgraph(:petersen))
    res = reduceto(paths[1], source)
    @test target_problem(res) isa QUBO

    best1 = findbest(source, BruteForce())
    best2 = findbest(target_problem(res), BruteForce())
    @test sort(extract_solution.(Ref(res), best2)) == sort(best1)
end

@testset "reduce factoring to ising" begin
    g = reduction_graph()
    paths = reduction_paths(Factoring, SpinGlass)

    # implement the reduction path
    factoring = Factoring(2, 1, 3)
    res = reduceto(paths[1], factoring)
    @test target_problem(res) isa SpinGlass
    sol = findbest(target_problem(res), BruteForce())
    @test all(solution_size.(Ref(factoring), extract_solution.(Ref(res), sol)) .== Ref(SolutionSize(0, true)))
end
