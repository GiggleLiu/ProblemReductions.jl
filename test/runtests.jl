using ProblemReductions
using Test

@testset "bit vector" begin
    include("bitvector.jl")
end

@testset "sat" begin
    include("sat.jl")
end
