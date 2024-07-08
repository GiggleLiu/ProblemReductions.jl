using ProblemReductions
using Test
using Documenter

@testset "bit vector" begin
    include("bitvector.jl")
end

@testset "models" begin
    include("models/models.jl")
end

@testset "rules" begin
    include("rules/rules.jl")
end

@testset "sat" begin
    include("sat.jl")
end

@testset "topology" begin
    include("topology.jl")
end

@testset "truth_table" begin
    include("truth_table.jl")
end

DocMeta.setdocmeta!(ProblemReductions, :DocTestSetup, :(using ProblemReductions); recursive=true)
Documenter.doctest(ProblemReductions; manual=false)