using Test
using ProblemReductions, Graphs

@testset "id to config" begin
    g = smallgraph(:petersen)
    J = randn(ne(g))
    h = randn(nv(g))
    @test id_to_config(SpinGlass(g, J, h), repeat([1, 2], 5)) == repeat([0, 1], 5)
end

@testset "terms" begin
    g = smallgraph(:petersen)
    J = randn(ne(g))
    h = randn(nv(g))
    terms = size_terms(SpinGlass(g, J, h))
    @test length(terms) == ne(g) + nv(g)
end
