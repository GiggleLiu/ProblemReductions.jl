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

function reduceto(::Type{<:SetPacking}, s::IndependentSet)
    subset_collection = Vector{Vector{Int}}()
    vertices_list = Vector{Int}()
    for v in vertices(s.graph)
        push!(vertices_list, v)
        push!(subset_collection, Vector{Int}())
    end
    for (i, v_set) in enumerate(edges(s.graph))
        for v in iterable(v_set)
            push!(subset_collection[findfirst(==(v), vertices_list)], i)
        end
    end
    return ReductionIndependentSetToSetPacking(SetPacking(subset_collection), vertices_list)
end

function extract_solution(::ReductionIndependentSetToSetPacking, sol)
    return sol
end

"""
$TYPEDEF

The reduction result of a Set Packing problem to an Independent Set problem.

### Fields
$TYPEDFIELDS
"""
struct ReductionSetPackingToIndependentSet{GT, ET} <: AbstractReductionResult
    target::IndependentSet{GT}  # the target problem
    subset_list::Vector{Vector{ET}} # The subset collection of the Set Packing problem
end
target_problem(res::ReductionSetPackingToIndependentSet) = res.target

function reduceto(::Type{<:IndependentSet{<:SimpleGraph}}, s::SetPacking)
    g = SimpleGraph(length(s.sets))
    for set_i=1:length(s.sets)
        for set_j=set_i+1:length(s.sets)
            for each_vertex_j in s.sets[set_j]
                if each_vertex_j in s.sets[set_i]
                    add_edge!(g, set_i, set_j) && break
                end
            end
        end
    end
    return ReductionSetPackingToIndependentSet(IndependentSet(g), s.sets)
end

function extract_solution(::ReductionSetPackingToIndependentSet, sol)
    return sol
end
