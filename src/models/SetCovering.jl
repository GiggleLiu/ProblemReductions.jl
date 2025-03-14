"""
$TYPEDEF

The Set Covering problem is defined as follow: given a universe of elements and a collection of subsets of the universe, each set is associated with a weight. 
The goal is to find a subset of sets that covers all the elements with the minimum total weight.

Positional arguments
-------------------------------
- `elements` is a vector of elements in the universe.
- `sets` is a vector of vectors, a collection of subsets of universe , each set is associated with a weight specified in `weights`.
- `weights` are associated with sets.

Example
-------------------------------
In the following example, we solve a Set Covering problem with 3 subsets and weights `[1,2,3]`.
```jldoctest
julia> using ProblemReductions

julia> subsets = [[1, 2, 3], [2, 4], [1, 4]]
3-element Vector{Vector{Int64}}:
 [1, 2, 3]
 [2, 4]
 [1, 4]

julia> weights = [1, 2, 3]
3-element Vector{Int64}:
 1
 2
 3

julia> setcovering = SetCovering(subsets, weights)
SetCovering{Int64, Int64, Vector{Int64}}([1, 2, 3, 4], [[1, 2, 3], [2, 4], [1, 4]], [1, 2, 3])

julia> num_variables(setcovering)  # degrees of freedom
3

julia> solution_size(setcovering, [1, 0, 1])  # size of a configuration
SolutionSize{Int64}(4, true)

julia> solution_size(setcovering, [0, 1, 1])
SolutionSize{Int64}(5, false)

julia> sc = set_weights(setcovering, [1, 2, 3])  # set the weights of the subsets
SetCovering{Int64, Int64, Vector{Int64}}([1, 2, 3, 4], [[1, 2, 3], [2, 4], [1, 4]], [1, 2, 3])
```
"""
struct SetCovering{ET, T, WT<:AbstractVector{T}} <: ConstraintSatisfactionProblem{T}
    elements::Vector{ET}
    sets::Vector{Vector{ET}}
    weights::WT
    function SetCovering(sets::Vector{Vector{ET}}, weights::AbstractVector{T}=UnitWeight(length(sets))) where {ET, T}
        @assert length(weights) == length(sets)
        elements = unique!(vcat(sets...))
        new{ET, T, typeof(weights)}(elements, sets, weights)
    end
end
Base.:(==)(a::SetCovering, b::SetCovering) = a.sets == b.sets && a.weights == b.weights && a.elements == b.elements

"""
Defined as the number of sets.
"""
problem_size(c::SetCovering) = (; num_sets=length(c.sets), num_elements=length(c.elements))

# variables interface
num_variables(gp::SetCovering) = length(gp.sets)
num_flavors(::Type{<:SetCovering}) = 2 # whether the set is selected (1) or not (0)

# weights interface
weights(c::SetCovering) = c.weights
set_weights(c::SetCovering, weights) = SetCovering(c.sets, weights)

# constraints interface
function constraints(c::SetCovering)
    return [LocalConstraint(num_flavors(c), findall(s->v in s, c.sets), [_is_satisfied_cover(config) for config in combinations(num_flavors(c), length(findall(s->v in s, c.sets)))]) for v in c.elements]
end
function _is_satisfied_cover(config)
    return count(isone, config) > 0
end
function objectives(c::SetCovering{T}) where T
    return [LocalSolutionSize(num_flavors(c), [i], [zero(T), w]) for (i, w) in zip(variables(c), weights(c))]
end
energy_mode(::Type{<:SetCovering}) = SmallerSizeIsBetter()

"""
    is_set_covering(c::SetCovering, config)

Return true if `config` (a vector of boolean numbers as the mask of sets) is a set covering of `sets`.
"""
function is_set_covering(c::SetCovering, config)
    @assert length(config) == num_variables(c)
    return length(c.elements) == length(unique!(vcat([c.sets[i] for i in 1:length(config) if config[i]==1]...)))
end