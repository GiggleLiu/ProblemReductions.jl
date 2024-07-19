"""
$TYPEDEF

The [set covering problem](https://queracomputing.github.io/GenericTensorNetworks.jl/dev/generated/SetCovering/).

Positional arguments
-------------------------------
* `sets` is a vector of vectors, a collection of subsets of universe , each set is associated with a weight specified in `weights`.
* `weights` are associated with sets.
"""

struct SetCovering{ET, WT<:AbstractVector} <: AbstractProblem
    sets::Vector{Vector{ET}}
    weights::WT
    function SetCovering(sets::Vector{Vector{ET}}, weights::AbstractVector=UnitWeight(length(sets))) where {ET}
        @assert length(weights) == length(sets)
        new{ET, typeof(weights)}(sets, weights)
    end
end
Base.:(==)(a::SetCovering, b::SetCovering) = a.sets == b.sets && a.weights == b.weights

#variables interface
variables(gp::SetCovering) = gp.sets
flavors(::Type{<:SetCovering}) = [0, 1] # whether the set is selected (1) or not (0)

# weights interface
parameters(c::SetCovering) = c.weights
set_parameters(c::SetCovering, weights) = SetCovering(c.sets, weights)

"""
    evaluate(c::SetCovering, config)
   
evaluate the energy of the set covering configuration `config`, the energy is the
sum of the weights of the sets that are selected. Config is a vector of boolean numbers.
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
    is_set_covering(sets::AbstractVector, config)

Return true if `config` (a vector of boolean numbers as the mask of sets) is a set covering of `sets`.
"""
function is_set_covering(c::SetCovering, config)
    @assert length(config) == num_variables(c)
    return Set(vcat(c.sets...)) == Set(vcat([c.sets[i] for i in 1:length(config) if config[i]==1]...))
end