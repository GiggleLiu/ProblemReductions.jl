abstract type AbstractProblem end

"""
    reduceto(::Type{TA}, x::AbstractProblem)

Reduce the problem `x` to a target problem of type `TA`.
"""
function reduceto end

"""
    extract_solution(::Type{TA}, x::AbstractProblem, sol)

Extract the solution `sol` of the target problem of type `TA` to the original problem `x`.
"""
function extract_solution end

struct SATProblem <: AbstractProblem
end

struct SpinGlassProblem{T} <: AbstractProblem
    graph::SimpleGraph{Int}
    J::Vector{T}
    h::Vector{T}
end

function reduceto(::Type{TA}, x::AbstractProblem) where TA<:AbstractProblem
end

function problem_reduction()
end