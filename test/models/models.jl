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

@testset "SetCovering" begin
    include("SetCovering.jl")
end