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
struct SetCovering{ET, WT<:AbstractVector} <: AbstractProblem
    elements::Vector{ET}
    sets::Vector{Vector{ET}}
    weights::WT
    function SetCovering(sets::Vector{Vector{ET}}, weights::AbstractVector=UnitWeight(length(sets))) where {ET}
        @assert length(weights) == length(sets)
        elements = unique!(vcat(sets...))
        new{ET, typeof(weights)}(elements, sets, weights)
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
parameters(c::SetCovering) = c.weights
set_parameters(c::SetCovering, weights) = SetCovering(c.sets, weights)

"""
    evaluate(c::SetCovering, config)
   
evaluate the energy of the set covering configuration `config`, the energy is the
sum of the weights of the sets that are selected but return typemax(eltype(weights)) if the set is not covered.
Config is a vector of boolean numbers.
""" 

function evaluate(c::SetCovering, config)
    @assert length(config) == num_variables(c)
    set_covering_energy(c.sets, c.weights, config )
end
function set_covering_energy(sets::AbstractVector, weights::AbstractVector, config)
    @assert length(sets) == length(weights) == length(config)
    !is_set_covering(SetCovering(sets, weights), config) && return typemax(eltype(weights))
    return sum(weights[i] * config[i] for i=1:length(weights))
end

"""
    is_set_covering(c::SetCovering, config)

Return true if `config` (a vector of boolean numbers as the mask of sets) is a set covering of `sets`.
"""
function is_set_covering(c::SetCovering, config)
    @assert length(config) == num_variables(c)
    return length(c.elements) == length(unique!(vcat([c.sets[i] for i in 1:length(config) if config[i]==1]...)))
end