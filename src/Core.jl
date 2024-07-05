abstract type AbstractProblem end

"""
    reduceto(::Type{TA}, x::AbstractProblem)

Reduce the problem `x` to a target problem of type `TA`.
"""
function reduceto end

"""
    extract_solution(::Type{TA}, y::AbstractProblem, sol)

Extract the solution `sol` of the target problem of type `TA` to the original problem `y`.
"""
function extract_solution end

