using Test, ProblemReductions, Graphs

@testset "pack bits" begin
    @test ProblemReductions.pack_bits([0, 1, 1]) == 6
end

@testset "factoring" begin
    # construct a factoring problem
    m = 2
    n = 3
    z = 15
    f = Factoring(m, n, z)
    @test variables(f) == [1, 2, 3, 4, 5]
    @test flavors(Factoring) == (0, 1)
    @test problem_size(f) == (; num_bits_first = 2, num_bits_second = 3)
    @test num_flavors(f) == 2
    @test solution_size(f, [0, 1, 1, 1, 0]) == SolutionSize(0, false)
    @test solution_size(f, [1, 1, 1, 0, 1]) == SolutionSize(0, true)
    @test findbest(f, BruteForce()) == [[1, 1, 1, 0, 1]]
end