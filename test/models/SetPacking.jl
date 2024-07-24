using Test, ProblemReductions

@testset "setpacking" begin
    # construct two inequivalent sets
    sets01 = [[1, 2, 5], [1, 3], [2, 4], [3, 6], [2, 3, 6]]
    sets02 = [[1, 3], [1, 2, 5], [2, 4], [3, 6], [2, 3, 6]]

    # construct corresponding SetPacking problems
    SP_01 = SetPacking(sets01)
    SP_02 = SetPacking(sets02)
    @test !(SP_01 == SP_02)
    @test SP_01 == SetPacking([[1, 2, 5], [1, 3], [2, 4], [3, 6], [2, 3, 6]])

    # variables
    @test variables(SP_01) == [1, 2, 3, 4, 5]
    @test num_variables(SP_01) == 5
    @test flavors(SetPacking) == [0, 1]

    # evaluate
    # a Positive examples
    cfg_values01 = [1, 0, 0, 1, 0]
    cfg01 = Dict(zip(sets01, cfg_values01))
    @test evaluate(SP_01, cfg01) == -2
    
    # a Negative example
    cfg_values02 = [1, 0, 1, 1, 0]
    cfg02 = Dict(zip(sets01, cfg_values02))
    @test evaluate(SP_01, cfg02) == Inf

    # test findbest function
    cfg_values03 = [0, 1, 1, 0, 0]
    cfg03 = Dict(zip(sets01, cfg_values03))
    cfg_values04 = [0, 0, 1, 1, 0]
    cfg04 = Dict(zip(sets01, cfg_values04))
    @test findbest(SP_01, BruteForce()) == [cfg01, cfg03, cg04] # "1" is superior to "0"
end