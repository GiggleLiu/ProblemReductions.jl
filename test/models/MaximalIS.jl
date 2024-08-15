using ProblemReductions, Test, Graphs

@testset "Maximal_IS" begin
    g = smallgraph(:petersen)
    mis = MaximalIS(g)
    @test mis isa MaximalIS
    @test variables(mis) == [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
    @test num_variables(mis) == 10
    @test flavors(MaximalIS) == [0, 1]
    @test parameters(mis) == [1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
    @test set_parameters(mis, [1, 5, 1, 4, 1, 3, 1, 2, 1, 2]) == MaximalIS(g,[1, 5, 1, 4, 1, 3, 1, 2, 1, 2])
    @test evaluate(mis, [1, 0, 0, 0, 0, 0, 0, 0, 0, 0]) == 1
end