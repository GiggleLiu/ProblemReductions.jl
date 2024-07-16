using Test

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