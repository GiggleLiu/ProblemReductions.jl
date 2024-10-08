"""
$TYPEDEF

The Set Covering problem is defined as follow: given a universe of elements and a collection of subsets of the universe, each set is associated with a weight. 
The goal is to find a subset of sets that covers all the elements with the minimum total weight.

Positional arguments
-------------------------------
* `elements` is a vector of elements in the universe.
* `sets` is a vector of vectors, a collection of subsets of universe , each set is associated with a weight specified in `weights`.
* `weights` are associated with sets.
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
variables(gp::SetCovering) = [1:length(gp.sets)...]
flavors(::Type{<:SetCovering}) = [0, 1] # whether the set is selected (1) or not (0)

# weights interface
weights(c::SetCovering) = c.weights
set_weights(c::SetCovering, weights) = SetCovering(c.sets, weights)

# constraints interface
function hard_constraints(c::SetCovering)
    return [LocalConstraint(findall(s->v in s, c.sets), :cover) for v in c.elements]
end
function is_satisfied(::Type{<:SetCovering{T}}, spec::LocalConstraint, config) where {T}
    @assert length(config) == num_variables(spec)
    return count(isone, config) > 0
end

function energy_terms(c::SetCovering)
    return [LocalConstraint([i], :set) for i in variables(c)]
end
function local_energy(::Type{<:SetCovering{ET, T}}, spec::LocalConstraint, config) where {ET, T}
    @assert length(config) == num_variables(spec)
    return T(first(config))
end

"""
    is_set_covering(c::SetCovering, config)

Return true if `config` (a vector of boolean numbers as the mask of sets) is a set covering of `sets`.
"""
function is_set_covering(c::SetCovering, config)
    @assert length(config) == num_variables(c)
    return length(c.elements) == length(unique!(vcat([c.sets[i] for i in 1:length(config) if config[i]==1]...)))
end