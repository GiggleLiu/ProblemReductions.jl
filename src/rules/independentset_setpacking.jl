"""
$TYPEDEF

The reduction result of an Independent Set problem to a Set Packing problem.

### Fields
$TYPEDFIELDS
"""
struct ReductionIndependentSetToSetPacking{ET} <: AbstractReductionResult
    target::SetPacking{ET}  # the target problem
    vertices_list::Vector{Int}
end
target_problem(res::ReductionIndependentSetToSetPacking) = res.target

@with_complexity 1 function reduceto(::Type{<:SetPacking}, s::IndependentSet)
    subset_collection = Vector{Vector{Int}}()
    vertices_list = Vector{Int}()
    for v in vertices(s.graph)
        push!(vertices_list, v)
        push!(subset_collection, Vector{Int}())
    end
    for (i, e) in enumerate(edges(s.graph))
        for v in _vec(e)
            push!(subset_collection[findfirst(==(v), vertices_list)], i)
        end
    end
    return ReductionIndependentSetToSetPacking(SetPacking(subset_collection), vertices_list)
end

function extract_solution(::ReductionIndependentSetToSetPacking, sol)
    return sol
end
