abstract type AbstractReductionResult end

"""
    target_problem(res::AbstractReductionResult) -> AbstractProblem

Return the target problem of the reduction result.
"""
function target_problem end

"""
    reduceto(::Type{TA}, x::AbstractProblem)

Reduce the problem `x` to a target problem of type `TA`.
Returns an instance of `AbstractReductionResult`.

### Arguments
- `TA`: The target problem type.
- `x`: The original problem.
"""
function reduceto end

"""
    extract_solution(::Type{TA}, y::AbstractProblem, sol)

Extract the solution `sol` of the target problem of type `TA` to the original problem `y`.

### Arguments
- `TA`: The target problem type.
- `y`: The original problem.
- `sol`: The solution of the target problem.
"""
function extract_solution end

include("spinglass_sat.jl")