"""
$TYPEDEF

The [set packing problem](https://queracomputing.github.io/GenericTensorNetworks.jl/dev/generated/SetPacking/), a generalization of independent set problem to hypergraphs.

Positional arguments
-------------------------------
* `sets` is a vector of vectors, each set is associated with a weight specified in `weights`.

Currently this type problem doesn't support weights.

Examples
-------------------------------
Under Development
"""
struct SetPacking{ET <: Vector} <: AbstractProblem
    sets::Vector{Vector{ET}}
    function SetPacking(sets::Vector{Vector{ET}} ) where {ET}
        new{ET}(sets)
    end
end
Base.:(==)(a::SetPacking, b::SetPacking) = ( a.sets == b.sets )

# Variables Interface
variables(c::SetPacking) = [1:length(c.sets)...]
flavors(::Type{<:SetPacking}) = [0, 1]

"""
    evaluate(c::SetPacking, config)

* First step: We check if `config` (a vector of boolean numbers as the mask of sets) is a set packing of `sets`;
* Second step: If it is a set packing, we return - (size(set packing)); Otherwise, we return Inf.
"""
"""
    is_set_packing(sets::AbstractVector, config)

Return true if `config` (a vector of boolean numbers as the mask of sets) is a set packing of `sets`.
"""
function evaluate(c::SetPacking, config)
    @assert length(config) == num_variables(c)
    if is_set_packing(c.sets, config)
        return - length(config)
    else
        return Inf
    end
end
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