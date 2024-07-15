using Test, ProblemReductions, Graphs
using ProblemReductions: Coloring, SimpleGraph, add_edge!, UnitWeight, variables, flavors, num_flavors,
 terms, evaluate, coloring_energy, is_vertex_coloring,set_parameters,parameters

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
    @test parameters(c) == UnitWeight()
    @test set_parameters(c, [1, 2, 2, 1]) == Coloring{3}(g, [1, 2, 2, 1])

    # evaluate,here I found the definition of Config is not clear, so I can't test the evaluate function
    @test evaluate(c,[0, 1, 2, 0]) == 1
    @test coloring_energy(terms(c),[1, 3, 2, 5],[0, 1, 2, 0]) == 3
end

