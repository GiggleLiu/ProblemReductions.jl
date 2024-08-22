using Test, ProblemReductions, Graphs

@testset "independentset_setpacking" begin
    function verify(IS)
        reduction_results = reduceto(SetPacking, IS)
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

    IS_01 = IndependentSet(g01)
    IS_02 = IndependentSet(g02)

    @test reduction_complexity(SetPacking, IS_01) == 1
    @test verify(IS_01)
    @test verify(IS_02)
end