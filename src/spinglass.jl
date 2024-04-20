struct SpinGlassProblem{T} <: AbstractProblem
    graph::SimpleGraph{Int}
    J::Vector{T}
    h::Vector{T}
end

function reduceto(::Type{<:SATProblem}, x::SpinGlassProblem)
end

function reduceto(::Type{<:SpinGlassProblem}, sat::SATProblem)
    sat.clauses
end

function problem_reduction()
end