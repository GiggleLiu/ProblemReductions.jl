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
struct SetPacking{ET, WT<:AbstractVector} <: AbstractProblem
    elements::Vector{ET}
    sets:: AbstractVector{<:AbstractVector{ET}}
    weights::WT
    function SetPacking(sets::AbstractVector{<:AbstractVector{ET}}, weights::WT=UnitWeight(length(sets))) where {ET, WT<:AbstractVector}
        elements = unique!(vcat(sets...))
        return new{ET, WT}(elements, sets, weights)
    end
end
Base.:(==)(a::SetPacking, b::SetPacking) = ( a.sets == b.sets )
problem_size(c::SetPacking) = (; num_elements = length(c.elements), num_sets = length(c.sets))

# Variables Interface
variables(c::SetPacking) = [1:length(c.sets)...]
flavors(::Type{<:SetPacking}) = [0, 1]

"""
    evaluate(c::SetPacking, config)

* First step: We check if `config` (a vector of boolean numbers as the mask of sets) is a set packing of `sets`;
* Second step: If it is a set packing, we return (size(set packing)); Otherwise, we return 0.
"""
function evaluate(c::SetPacking, config)
    @assert length(config) == num_variables(c)
    if is_set_packing(c.sets, config)
        return - count(x -> x == 1, config)
    else
        return 0
    end
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