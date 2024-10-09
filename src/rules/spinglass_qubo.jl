"""
$TYPEDEF

The reduction result of a qubo to a spin glass problem.

### Fields
- `spinglass::SpinGlass{GT, T}`: the spin glass problem.

We only consider a simple reduction from QUBO to SpinGlass(the graph must be `SimpleGraph`).
"""
struct ReductionQUBOToSpinGlass{GT, T} <: AbstractReductionResult
    spinglass::SpinGlass{GT, T}
end

target_problem(res::ReductionQUBOToSpinGlass) = res.spinglass

function reduceto(::Type{<:SpinGlass{<:SimpleGraph}}, qubo::QUBO)
    sg = spin_glass_from_matrix(2 * qubo.matrix, (-).(vec(sum(qubo.matrix, dims=1))) .- vec(sum(qubo.matrix, dims=2)))
    return ReductionQUBOToSpinGlass(sg)
end 
extract_solution(::ReductionQUBOToSpinGlass, sol) = sol .== -1

"""
$TYPEDEF

The reduction result of a spin glass to a QUBO problem.

### Fields
- `qubo::QUBO{WT}`: the QUBO problem.
"""
struct ReductionSpinGlassToQUBO{WT} <: AbstractReductionResult
    qubo::QUBO{WT}
end
target_problem(res::ReductionSpinGlassToQUBO) = res.qubo

function reduceto(::Type{<:QUBO}, sg::SpinGlass{<:SimpleGraph})
    matrix = zeros(eltype(sg.J), nv(sg.graph), nv(sg.graph))
    for (w, c) in zip(sg.J, edges(sg.graph))
        matrix[c.src, c.dst] += w
        matrix[c.dst, c.src] += w
        matrix[c.src, c.src] -= w
        matrix[c.dst, c.dst] -= w
    end
    for (i, h) in enumerate(sg.h)
        matrix[i, i] -= h
    end
    return ReductionSpinGlassToQUBO(QUBO(matrix))
end

extract_solution(::ReductionSpinGlassToQUBO, sol) = 1 .- 2 .* sol 