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

julia> get_size(setcovering, [1, 0, 1])  # size of a configuration
4

julia> get_size(setcovering, [0, 1, 1])
3

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
flavors(::Type{<:SetCovering}) = (0, 1) # whether the set is selected (1) or not (0)

# weights interface
weights(c::SetCovering) = c.weights
set_weights(c::SetCovering, weights) = SetCovering(c.sets, weights)

# constraints interface
function hard_constraints(c::SetCovering)
    return [HardConstraint(findall(s->v in s, c.sets), :cover) for v in c.elements]
end
function is_satisfied(::Type{<:SetCovering{T}}, spec::HardConstraint, config) where {T}
    @assert length(config) == num_variables(spec)
    return count(isone, config) > 0
end

function soft_constraints(c::SetCovering)
    return [SoftConstraint([i], :set, w) for (i, w) in zip(variables(c), weights(c))]
end
function local_size(::Type{<:SetCovering{ET, T}}, spec::SoftConstraint{WT}, config) where {ET, T, WT}
    @assert length(config) == num_variables(spec)
    return WT(first(config)) * spec.weight
end

"""
    is_set_covering(c::SetCovering, config)

Return true if `config` (a vector of boolean numbers as the mask of sets) is a set covering of `sets`.
"""
function is_set_covering(c::SetCovering, config)
    @assert length(config) == num_variables(c)
    return length(c.elements) == length(unique!(vcat([c.sets[i] for i in 1:length(config) if config[i]==1]...)))
end