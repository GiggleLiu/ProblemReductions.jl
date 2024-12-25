using Test, ProblemReductions, Graphs

@testset "independentset_setpacking" begin
    function verify(IS)
        reduction_results = reduceto(SetPacking{<:SimpleGraph}, IS)
        SP = reduction_results |> target_problem
        sol_SP = findbest(SP, BruteForce())
        s1 = Set(findbest(IS, BruteForce()))
        s2 = Set( unique( extract_solution.(Ref(reduction_results), sol_SP) ) )
        return s2 == s1
    end

    g01 = SimpleGraph(4)
    add_edge!(g01, 1, 2) 
    add_edge!(g01, 1, 3)
    add_edge!(g01, 3, 4)
    add_edge!(g01, 2, 3)

    g02 = SimpleGraph(4)
    add_edge!(g02, 1, 3) 
    add_edge!(g02, 1, 2)
    add_edge!(g02, 2, 3)
    add_edge!(g02, 3, 4)

    hg = HyperGraph(5, [[1, 2], [2, 3, 4]])
    udg = UnitDiskGraph([(0.0, 0.0), (1.0, 0.0), (0.0, 1.0), (1.0, 1.0)], 1.2)
    gg = GridGraph(Bool[1 0; 1 1], 1.2)

    IS_01 = IndependentSet(g01)
    IS_02 = IndependentSet(g02)
    IS_hg = IndependentSet(hg)
    IS_udg = IndependentSet(udg)
    IS_gg = IndependentSet(gg)

    @test verify(IS_01)
    @test verify(IS_02)
    @test verify(IS_hg)
    @test verify(IS_udg)
    @test verify(IS_gg)
end

@testset "setpacking_independentset" begin
    function verify(SP)
        reduction_results = reduceto(IndependentSet{<:SimpleGraph}, SP)
        IS = reduction_results |> target_problem
        sol_IS = findbest(IS, BruteForce())
        s1 = Set(findbest(SP, BruteForce()))
        s2 = Set( unique( extract_solution.(Ref(reduction_results), sol_IS) ) )
        return s2 == s1
    end

    sets01 = [[1, 2, 5], [1, 3], [2, 4], [3, 6], [2, 3, 6]]
    sets02 = [[1, 3], [1, 2, 5], [2, 4], [3, 6], [2, 3, 6]]

    SP_01 = SetPacking(sets01)
    SP_02 = SetPacking(sets02)


    @test verify(SP_01)
    @test verify(SP_02)
end