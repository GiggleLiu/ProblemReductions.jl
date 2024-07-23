"""
$TYPEDEF

The base type for a reduction result.
"""
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
    reduction_complexity(::Type{TA}, x::AbstractProblem) -> Int

The complexity of the reduction from the original problem to the target problem.

### Arguments
- `TA`: The target problem type.
- `x`: The original problem.
"""
function reduction_complexity end

"""
    extract_solution(reduction::AbstractReductionResult, solution)

Extract the solution `solution` of the target problem to the original problem.

### Arguments
- `reduction`: The reduction result.
- `solution`: The solution of the target problem.
"""
function extract_solution end

include("spinglass_sat.jl")
include("spinglass_maxcut.jl")