using Test, ProblemReductions, Graphs

@testset "setcovering" begin
    c = SetCovering([[1, 2], [2, 3], [2, 3, 4]], [1, 1, 2])
    # constructor function
    @test c.elements == [1, 2, 3, 4]
    @test variables(c)==[1, 2, 3]
    @test num_variables(c) == 3
    @test flavors(SetCovering) == [0, 1]
    @test problem_size(c) == (; num_sets=3, num_elements=4)
    
    # weights interface
    @test parameters(c) == [1, 1, 2]
    @test set_parameters(c, [1, 2, 3]) == SetCovering([[1, 2], [2, 3], [2, 3, 4]], [1, 2, 3])
    
    # evaluate
    @test evaluate(c, [0, 1, 1]) == typemax(Int)
    @test evaluate(c, [1, 0, 1]) == 3
    @test set_covering_energy(c.sets, [1, 1, 2], [0, 0, 1]) == typemax(Int)
    @test is_set_covering(c,[1,0,1]) == true
    @test is_set_covering(c,[0,0,1]) == false
    
    # findbest
    @test findbest(c, BruteForce()) == [[1, 0, 1]]
    @test findbest(c, BruteForce()) == [[1, 0, 1]]
    g = SetCovering([[1, 2], [1, 3, 4], [2, 3]], [1, 1, 2])
    @test findbest(g, BruteForce()) == [[1, 1, 0]]
end