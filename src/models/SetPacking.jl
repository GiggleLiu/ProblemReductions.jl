"""
$(TYPEDEF)
SetPacking(elements::AbstractVector, sets::AbstractVector, weights::AbstractVector=UnitWeight(length(sets))) -> SetPacking

The [set packing problem](https://queracomputing.github.io/GenericTensorNetworks.jl/dev/generated/SetPacking/)
is to find a set of sets, where each set is pairwise disjoint from each other.

Positional arguments
-------------------------------
* `elements` is a vector of elements in the universe.
* `sets` is a vector of vectors, each set is associated with a weight specified in `weights`.
* `weights` are associated with sets. Defaults to `UnitWeight(length(sets))`.
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
Base.:(==)(a::SetPacking, b::SetPacking) = ( a.sets == b.sets )
problem_size(c::SetPacking) = (; num_elements = length(c.elements), num_sets = length(c.sets))

# Variables Interface
variables(c::SetPacking) = [1:length(c.sets)...]
flavors(::Type{<:SetPacking}) = [0, 1]

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
    return [LocalConstraint(v, :independent) for v in values(d)]
end
function is_satisfied(::Type{<:SetPacking}, spec::LocalConstraint, config)
    @assert length(config) == num_variables(spec)
    return count(isone, config) <= 1
end

function energy_terms(c::SetPacking)  # sets sharing the same element
    return [LocalConstraint([s], :set) for s in 1:length(c.sets)]
end

function local_energy(::Type{<:SetPacking}, spec::LocalConstraint, config)
    @assert length(config) == num_variables(spec) == 1
    return -first(config)
end

"""
    is_set_packing(sets::AbstractVector, config)

Return true if `config` (a vector of boolean numbers as the mask of sets) is a set packing of `sets`.
"""
function is_set_packing(sets::AbstractVector{ST}, config) where ST
    d = Dict{eltype(ST), Int}()
    for i=1:length(sets)
        if !iszero(config[i])
            for e in sets[i]
                d[e] = get(d, e, 0) + 1
            end
        end
    end
    return all(isone, values(d))
end