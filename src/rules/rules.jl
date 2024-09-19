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
Returns the polynomial order of the reduction.

!!! note
    The problem size measure is problem dependent. Please check [`problem_size`](@ref) for the problem size measure.

### Arguments
- `TA`: The target problem type.
- `x`: The original problem.
"""
function reduction_complexity(::Type{TA}, x::AbstractProblem) where TA <: AbstractProblem
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

macro with_complexity(i::Int, ex::Expr)
    @assert ex.head == :function
    if ex.args[1].head == :call
        @assert ex.args[1].args[1] == :reduceto && length(ex.args[1].args) == 3
        esc(:($(Expr(:(=), Expr(:call, :reduction_complexity, ex.args[1].args[2], ex.args[1].args[3]), i)); $ex))
    elseif ex.args[1].head == :where
        @assert ex.args[1].args[1].head == :call
        @assert ex.args[1].args[1].args[1] == :reduceto && length(ex.args[1].args[1].args) == 3
        esc(:($(Expr(:(=), Expr(:where, Expr(:call, :reduction_complexity, ex.args[1].args[1].args[2], ex.args[1].args[1].args[3]), ex.args[1].args[2:end]...), Expr(:block, i))); $ex))
    else
        error("Invalid macro usage")
    end
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
include("sat_circuit.jl")
