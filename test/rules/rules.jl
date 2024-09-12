using Test, ProblemReductions, Graphs

@testset "spinglass_sat" begin
    include("spinglass_sat.jl")
end

@testset "spinglass_maxcut" begin
    include("spinglass_maxcut.jl")
end

@testset "spinglass_qubo" begin
    include("spinglass_qubo.jl")
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
@testset "sat_3sat" begin
    include("sat_3sat.jl")
end

@testset "sat_independentset" begin
    include("sat_independentset.jl")
end

@testset "sat_dominatingset" begin
    include("sat_dominatingset.jl")
end

@testset "independentset_setpacking" begin
    include("independentset_setpacking.jl")
end

@testset "circuit_sat" begin
    include("circuit_sat.jl")
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
    ksat = KSatisfiability{3}( CNF([CNFClause([BoolVar(:a), BoolVar(:b), BoolVar(:c)])]) )
    graph2 = HyperGraph(3, [[1, 2], [1], [2,3], [2]])
    spinglass2 = SpinGlass(graph2, [1, 2, 1, -1])
    qubo = QUBO([0 1 -2; 1 0 -2; -2 -2 6])
    is = IndependentSet(graph)
    is2 = IndependentSet(graph2)
    for (source, target_type) in [
            # please add more tests here
            circuit => SpinGlass,
            maxcut => SpinGlass,
            spinglass => MaxCut,
            vertexcovering => SetCovering,
            sat => Coloring{3},
            spinglass2 => MaxCut,
            qubo => SpinGlass,
            spinglass2 => QUBO,
            sat => KSatisfiability,
            ksat => Satisfiability,
            sat => IndependentSet,
            sat => DominatingSet,
            is => SetPacking,
            is2 => SetPacking
        ]
        @info "Testing reduction from $(typeof(source)) to $(target_type)"
        # directly solve
        best_source = findbest(source, BruteForce())

        # reduce and solve
        result = reduceto(target_type, source)
        target = target_problem(result)
        best_target = findbest(target, BruteForce())

        # extract the solution
        best_source_extracted_single = unique( extract_solution.(Ref(result), best_target) )
        best_source_extracted_multiple = extract_multiple_solutions(result, best_target)

        # check if the solutions are the same
        @test best_source_extracted_single ⊆ best_source
        @test Set(best_source_extracted_multiple) == Set(best_source)
    end

end
