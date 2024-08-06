using Test, ProblemReductions, Graphs

@testset "spinglass_sat" begin
    include("spinglass_sat.jl")
end

@testset "spinglass_maxcut" begin
    include("spinglass_maxcut.jl")
end
@testset "vertexcovering_setcovering" begin
    include("vertexcovering_setcovering.jl")
end
@testset "sat_coloring.jl" begin
    include("sat_coloring.jl")
end

@testset "factoring_sat.jl" begin
    include("factoring_sat.jl")
end

@testset "rules" begin
    circuit = CircuitSAT(@circuit begin
        x = a ∨ ¬b
        y = ¬c ∨ b
        z = x ∧ y ∧ a
    end)
    graph = smallgraph(:petersen)
    maxcut = MaxCut(graph)
    spinglass = SpinGlass(graph, [1,2,1,2,1,2,1,2,1,2,1,2,1,2,1])
    vertexcovering = VertexCovering(graph, [1,2,1,2,1,2,1,2,1,2])
    sat = Satisfiability(CNF([CNFClause([BoolVar(:a), BoolVar(:b)])]))
    graph2 = HyperGraph(3, [[1, 2], [1], [2,3], [2]])
    spinglass2 = SpinGlass(graph2, [1, 2, 1, -1])
    for (source, target_type) in [
            # please add more tests here
            circuit => SpinGlass,
            maxcut => SpinGlass,
            spinglass => MaxCut,
            vertexcovering => SetCovering,
            sat => Coloring{3},
            spinglass2 => MaxCut
        ]
        # directly solve
        best_source = findbest(source, BruteForce())

        # reduce and solve
        result = reduceto(target_type, source)
        target = target_problem(result)
        best_target = findbest(target, BruteForce())

        # extract the solution
        best_source_extracted = extract_solution.(Ref(result), best_target)

        # check if the solutions are the same
        @test unique!(sort(best_source)) == unique!(sort(best_source_extracted))
    end
end
