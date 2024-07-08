using Test

@testset "spinglass_sat" begin
    include("spinglass_sat.jl")
end

@testset "rules" begin
    circuit = @circuit begin
        x = a ∨ ¬b
        y = ¬c ∨ b
        z = x ∧ y ∧ a
    end
    for (source, target_type) in [
            circuit => SpinGlass
        ]
        best_source = findbest(source)
        result = reduceto(target_type, best_source)
        target = target_problem(result)
        best_target = findbest(target)
        best_source_extracted = extract_solution(result, best_target)
        @test best_source == best_source_extracted
    end
end