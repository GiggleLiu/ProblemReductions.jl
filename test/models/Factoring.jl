using Test, ProblemReductions, Graphs

@testset "pack bits" begin
    @test ProblemReductions.pack_bits([0, 1, 1]) == 6
end

@testset "read_solution" begin
    f = Factoring(3, 2, 8)
    @test ProblemReductions.read_solution(f, [0, 0, 1, 0, 1]) == (4, 2)
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

@testset "is_factoring" begin
    f = Factoring(2, 2, 6)
    @test is_factoring(f, [0, 1, 1, 1]) == true
    @test is_factoring(f, [0, 1, 1, 0]) == false

    f1 = Factoring(3, 2, 8)
    @test is_factoring(f1, [0, 0, 1, 0, 1]) == true
    @test is_factoring(f1, [0, 0, 1, 1, 0]) == false
end