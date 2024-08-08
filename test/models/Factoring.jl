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
    @test flavors(Factoring) == [0, 1]
    @test num_flavors(f) == 2
    @test evaluate(f, [0, 1, 1, 1, 0]) == 1
    @test evaluate(f, [1, 1, 1, 0, 1]) == 0
    @test findbest(f, BruteForce()) == [[1, 1, 1, 0, 1]]
end