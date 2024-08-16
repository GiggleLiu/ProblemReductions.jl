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

@with_complexity 1 function reduceto(::Type{<:SpinGlass}, qubo::QUBO)
    sg = spin_glass_from_matrix(2 * qubo.matrix, (-).(vec(sum(qubo.matrix, dims=1))) .- vec(sum(qubo.matrix, dims=2)))
    return ReductionQUBOToSpinGlass(sg)
end 
extract_solution(::ReductionQUBOToSpinGlass, sol) = sol .== -1
# extract_multiple_solutions(res::ReductionQUBOToSpinGlass, sol_set) = unique( extract_solution.(Ref(res), sol_set) ) 

"""
$TYPEDEF

The reduction result of a spin glass to a QUBO problem.

### Fields
- `qubo::QUBO{WT}`: the QUBO problem.
"""
struct ReductionSpinGlassToQUBO{WT}
    qubo::QUBO{WT}
end
target_problem(res::ReductionSpinGlassToQUBO) = res.qubo

@with_complexity 1 function reduceto(::Type{<:QUBO}, sg::SpinGlass)
    @assert all(e->length(e) <= 2, vedges(sg.graph)) "Invalid graph with hyperedges: $(sg.graph)"
    matrix = zeros(eltype(sg.weights), nv(sg.graph), nv(sg.graph))
    for (w, c) in zip(sg.weights, vedges(sg.graph))
        if length(c) == 2  # simple edge
            matrix[c[1], c[2]] += w
            matrix[c[2], c[1]] += w
            matrix[c[1], c[1]] -= w
            matrix[c[2], c[2]] -= w
        else # onsite term
            matrix[c[1], c[1]] -= w
        end
    end
    return ReductionSpinGlassToQUBO(QUBO(matrix))
end

extract_solution(::ReductionSpinGlassToQUBO, sol) = 1 .- 2 .* sol
# extract_multiple_solutions(res::ReductionSpinGlassToQUBO, sol_set) = unique( extract_solution.(Ref(res), sol_set) ) 