using Test, ProblemReductions

@testset "utils" begin
    # 2 flavors, 3 variables
    @test ProblemReductions.combinations(2, 3) == [[0, 0, 0], [1, 0, 0], [0, 1, 0], [1, 1, 0], [0, 0, 1], [1, 0, 1], [0, 1, 1], [1, 1, 1]]
    @test ProblemReductions.combinations(3, 2) == [[0, 0], [1, 0], [2, 0], [0, 1], [1, 1], [2, 1], [0, 2], [1, 2], [2, 2]]
end

@testset "UnitWeight" begin
    w = UnitWeight(3)
    @test w[1] == 1
    @test w[2] == 1
    @test w[3] == 1
    @test w[1:2] === UnitWeight(2)
end

@testset "Circuit" begin
    include("Circuit.jl")
end

@testset "SpinGlass" begin
    include("SpinGlass.jl")
end

@testset "Coloring" begin
    include("Coloring.jl")
end

@testset "Satisfiability" begin
    include("Satisfiability.jl")
end

@testset "SetCovering" begin
    include("SetCovering.jl")
end

@testset "Maxcut" begin
    include("MaxCut.jl")
end

@testset "IndependentSet" begin
  include("IndependentSet.jl")
end

@testset "VertexCovering" begin
    include("VertexCovering.jl")
end

@testset "SetPacking" begin
    include("SetPacking.jl")
end

@testset "DominatingSet" begin
    include("DominatingSet.jl")
end

@testset "QUBO" begin
    include("QUBO.jl")
end

@testset "Factoring" begin
    include("Factoring.jl")
end

@testset "Matching" begin
    include("Matching.jl")
end

@testset "MaximalIS" begin
    include("MaximalIS.jl")
end

@testset "Paintshop" begin
    include("Paintshop.jl")
end

@testset "BMF" begin
    include("BMF.jl")
end

@testset "BicliqueCover" begin
    include("BicliqueCover.jl")
end

