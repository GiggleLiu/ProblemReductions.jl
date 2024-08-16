using ProblemReductions, Test
using ProblemReductions:paint_shop_coloring_from_config

@testset "paint shop" begin
    #test1 
    ps1 = PaintShop(["a","b","a","c","c","b"])
    @test ps1 isa PaintShop
    @test ps1.isfirst == [1,1,0,1,0,0]
    @test variables(ps1) == ["a","b","c"]
    @test num_variables(ps1) == 3
    @test flavors(ps1) == [0, 1]

    #test2 We could use number for the variables for our convenience
    ps2 = PaintShop([1,2,1,2,3,3])
    @test ps2 isa PaintShop
    @test ps2.isfirst == [1,1,0,0,1,0]
    @test variables(ps2) == [1,2,3]
    @test num_variables(ps2) == 3
    @test num_flavors(ps2) == 2
    @test paint_shop_coloring_from_config(ps2, [1,1,0]) == [1,1,0,0,0,1]
    @test evaluate(ps2, [1,1,0]) == 2
    @test findbest(ps2, BruteForce()) == [[1,1,0],[0,0,1]]
end