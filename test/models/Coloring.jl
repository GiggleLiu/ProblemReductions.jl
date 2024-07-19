using Test, ProblemReductions, Graphs

# create a graph

@testset "coloring" begin
    # constructor function
    @test flavors(Coloring{3}) == [0,1,2]
    @test num_flavors(Coloring{3}) == 3
    
    g = SimpleGraph(4)
    add_edge!(g, 1, 2)
    add_edge!(g, 2, 3)
    add_edge!(g, 3, 4)
    add_edge!(g, 4, 1)
    c = Coloring{3}(g, UnitWeight(nv(g)))
    c2 = Coloring{3}(g)
    @test c2 == c
    @test c.graph == g && c.weights isa UnitWeight
    @test variables(c) == [1, 2, 3, 4]

    # weights interface
    @test parameters(c) == UnitWeight(nv(g))
    @test set_parameters(c, [1, 2, 2, 1]) == Coloring{3}(g, [1, 2, 2, 1])

    # evaluate,here I found the definition of Config is not clear, so I can't test the evaluate function
    @test evaluate(c,[0, 1, 2, 0]) == 1
    @test coloring_energy(ProblemReductions.vedges(c.graph), [1, 3, 2, 5], [0, 1, 2, 0]) == 3
end

