"""
$TYPEDEF

The base type for a reduction result.
"""
abstract type AbstractReductionResult end

# identity reduction
struct IdentityReductionResult{T} <: AbstractReductionResult
    problem::T
end

"""
    target_problem(res::AbstractReductionResult) -> AbstractProblem

Return the target problem of the reduction result.
"""
function target_problem end
target_problem(res::IdentityReductionResult) = res.problem

"""
    reduceto(problem_type::Type{<:AbstractProblem}, problem::AbstractProblem) -> AbstractReductionResult
    reduceto(path::ReductionPath, problem::AbstractProblem) -> ConcatenatedReduction

Reduce the problem `problem` to a target problem.
If the target problem is a single problem type, reduce the problem `problem` to a target problem of type.
Then the result is an instance of [`AbstractReductionResult`](@ref).
Otherwise, if the target problem is a reduction path, implement a reduction path on a problem. Then the result is a [`ConcatenatedReduction`](@ref) instance.

### Arguments
- `problem_type::Type{<:AbstractProblem}` or `path::ReductionPath`: The target problem type or a reduction path.
- `problem::AbstractProblem`: The original problem.
"""
function reduceto end

"""
    reduce_size(::Type{T}, ::Type{S}, size)

Return the size of the target problem `T` after reducing the source problem `S` to `T`.

!!! note
    The problem size measure is problem dependent. Please check [`problem_size`](@ref) for the problem size measure.

### Arguments
- `T`: The target problem type.
- `S`: The source problem type.
- `size`: The size of the source problem.
"""
function reduce_size(::Type{TA}, x::AbstractProblem) where TA <: AbstractProblem
    @warn "The complexity of the reduction is not defined for the target problem type: $TA and source problem type: $(typeof(x)), default to 1."
    return 1
end

"""
    extract_solution(reduction::AbstractReductionResult, solution)

Extract the solution `solution` of the target problem to the original problem.

### Arguments
- `reduction`: The reduction result.
- `solution`: The solution of the target problem.
"""
function extract_solution end
extract_solution(::IdentityReductionResult, solution) = solution

"""
    extract_multiple_solutions(reduction::AbstractReductionResult, solution_set)

Extract multiple solutions together `solution_set` of the target problem to the original problem.

### Arguments
- `reduction`: The reduction result.
- `solution_set`: The set of multiple solutions of the target problem.
"""
function extract_multiple_solutions(reduction::AbstractReductionResult, solution_set)
    return unique( extract_solution.(Ref(reduction), solution_set) )
end

include("spinglass_sat.jl")
include("spinglass_maxcut.jl")
include("sat_3sat.jl")
include("spinglass_qubo.jl")
include("sat_coloring.jl")
include("vertexcovering_setcovering.jl")
include("factoring_sat.jl")
include("sat_independentset.jl")
include("sat_dominatingset.jl")
include("independentset_setpacking.jl")
include("circuit_sat.jl")
include("vertexcovering_independentset.jl")
include("matching_setpacking.jl")
include("BMF_BicliqueCover.jl")