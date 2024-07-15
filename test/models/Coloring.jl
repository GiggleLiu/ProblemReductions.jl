using Test, ProblemReductions, Graphs
using ProblemReductions: SimpleGraph, add_edge!, UnitWeight, variables, flavors, num_flavors, terms

# create a graph
g = SimpleGraph(4)
add_edge!(g, 1, 2)
add_edge!(g, 2, 3)
add_edge!(g, 3, 4)
add_edge!(g, 4, 1)

@testset "coloring" begin
    # constructor function
    c = Coloring{3}(g)
    @test c.graph == g && c.weights isa UnitWeight
    @test variables(c) == [1, 2, 3, 4]
    @test flavors(c) == [0,1,2]
    @test num_flavors(c) == 3
    @test terms(c)==[[1, 2], [2, 3], [3, 4], [4,1]]
    
end

