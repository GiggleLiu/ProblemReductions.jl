"""
$(TYPEDEF)
SetPacking(elements::AbstractVector, sets::AbstractVector, weights::AbstractVector=UnitWeight(length(sets))) -> SetPacking

A packing is a set of sets where each set is pairwise disjoint from each other. The maximum (weighted) packing problem is to find the maximum packing for a given union and a set of subsets.

Fields
-------------------------------
- `elements` is a vector of elements in the universe.
- `sets` is a vector of vectors, each set is associated with a weight specified in `weights`.
- `weights` are associated with sets. Defaults to `UnitWeight(length(sets))`.

Example
-------------------------------
In the following example, we define a set packing problem with five subsets.
To define a `SetPacking` problem, we need to specify the set of subsets and possibily the weights associated with these subsets.
The weights are set as unit by default in the current version and might be generalized to arbitrary positive weights in the following development.
Besides, the elements would be automatically counted by the construction function.
```jldoctest
julia> using ProblemReductions

julia> sets = [[1, 2, 5], [1, 3], [2, 4], [3, 6], [2, 3, 6]]
5-element Vector{Vector{Int64}}:
 [1, 2, 5]
 [1, 3]
 [2, 4]
 [3, 6]
 [2, 3, 6]

julia> SP = SetPacking(sets)
SetPacking{Int64, Int64, UnitWeight}([1, 2, 5, 3, 4, 6], [[1, 2, 5], [1, 3], [2, 4], [3, 6], [2, 3, 6]], [1, 1, 1, 1, 1])

julia> num_variables(SP)  # degrees of freedom
5

julia> flavors(SP)  # flavors of the subsets
(0, 1)

julia> solution_size(SP, [1, 0, 0, 1, 0]) # Positive sample: -(size) of a packing
SolutionSize{Int64}(2, true)

julia> solution_size(SP, [1, 0, 1, 1, 0]) # Negative sample: 0
SolutionSize{Int64}(3, false)

julia> findbest(SP, BruteForce())  # solve the problem with brute force
3-element Vector{Vector{Int64}}:
 [0, 1, 1, 0, 0]
 [1, 0, 0, 1, 0]
 [0, 0, 1, 1, 0]
```
"""
struct SetPacking{ET, T, WT<:AbstractVector{T}} <: ConstraintSatisfactionProblem{T}
    elements::Vector{ET}
    sets::Vector{Vector{ET}}
    weights::WT
    function SetPacking(sets::Vector{Vector{ET}}, weights::AbstractVector{T}=UnitWeight(length(sets))) where {ET, T}
        elements = unique!(vcat(sets...))
        return new{ET, T, typeof(weights)}(elements, sets, weights)
    end
end
Base.:(==)(a::SetPacking, b::SetPacking) = ( a.sets == b.sets && a.weights == b.weights && a.elements == b.elements)
problem_size(c::SetPacking) = (; num_elements = length(c.elements), num_sets = length(c.sets))

# Variables Interface
num_variables(c::SetPacking) = length(c.sets)
num_flavors(::Type{<:SetPacking}) = 2

weights(c::SetPacking) = c.weights
set_weights(c::SetPacking, weights::Vector{T}) where {T} = SetPacking(c.sets, weights)

# constraints interface
function hard_constraints(c::SetPacking)  # sets sharing the same element
    d = Dict{eltype(c.elements), Vector{Int}}()
    for (i, set) in enumerate(c.sets)
        for e in set
            push!(get!(()->Int[], d, e), i)
        end
    end
    return [HardConstraint(num_flavors(c), v, [_is_satisfied_set_packing(config) for config in combinations(num_flavors(c), length(v))]) for v in values(d)]
end
function _is_satisfied_set_packing(config)
    return count(isone, config) <= 1
end

function local_solution_size(c::SetPacking{T}) where T
    return [LocalSolutionSize(num_flavors(c), [s], [zero(T), w]) for (w, s) in zip(weights(c), 1:length(c.sets))]
end

energy_mode(::Type{<:SetPacking}) = LargerSizeIsBetter()

"""
    is_set_packing(sp::SetPacking, config)

Return true if `config` (a vector of boolean numbers as the mask of sets) is a set packing of `sp`.
"""
function is_set_packing(sp::SetPacking, config)
    d = Dict{eltype(sp.elements), Int}()
    for i=1:length(sp.sets)
        if !iszero(config[i])
            for e in sp.sets[i]
                d[e] = get(d, e, 0) + 1
            end
        end
    end
    return all(isone, values(d))
end