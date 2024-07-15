using Test, ProblemReductions, Graphs
using ProblemReductions: Coloring, SimpleGraph, add_edge!, UnitWeight, variables, flavors, num_flavors, terms,
    get_weights, evaluate, coloring_energy, is_vertex_coloring,chweights

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
    c = Coloring{3}(g,UnitWeight())
    @test c.graph == g && c.weights isa UnitWeight
    @test variables(c) == [1, 2, 3, 4]
    @test terms(c)==[[1, 2],[1,4],[2, 3], [3, 4]]

    # weights interface
    @test get_weights(c) == UnitWeight()
    @test get_weights(c, 1) == fill(UnitWeight(), 3)

    # evaluate,here I found the definition of Config is not clear, so I can't test the evaluate function
    @test evaluate(c, [0, 1, 2, 0]) == 1
   
    
end

