using Test, ProblemReductions, Graphs

@testset "rules" begin
    graph = smallgraph(:petersen)
    # Spin glass
    J = randn(ne(graph))
    h = randn(nv(graph))
    sg = SpinGlass(graph, J, h)

    # MaxCut
    weights = randn(nv(graph))
    idp = IndependentSet(graph, weights)

    problem_set = [
    ]
end