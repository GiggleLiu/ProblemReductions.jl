"""
$TYPEDEF

The [binary paint shop problem](https://queracomputing.github.io/GenericTensorNetworks.jl/dev/generated/PaintShop/).

Positional arguments
-------------------------------
* `sequence` is a vector of symbols, each symbol is associated with a color.
* `isfirst` is a vector of boolean numbers, indicating whether the symbol is the first appearance in the sequence.
"""
struct PaintShop{LT} <: ConstraintSatisfactionProblem{Int}
    sequence::Vector{LT}
    isfirst::Vector{Bool}
    function PaintShop(sequence::AbstractVector{T}) where T
        @assert all(l->count(==(l), sequence)==2, sequence)
        n = length(sequence)
        isfirst = [findfirst(==(sequence[i]), sequence) == i for i=1:n]
        new{eltype(sequence)}(sequence, isfirst)
    end
end

variables(gp::PaintShop) = unique(gp.sequence)
flavors(::Type{<:PaintShop}) = [0, 1]
problem_size(c::PaintShop) = (; sequence_length=length(c.sequence))
Base.:(==)(a::PaintShop, b::PaintShop) = a.sequence == b.sequence && a.isfirst == b.isfirst

# constraints interface
function energy_terms(c::PaintShop)
    # constraints on alphabets with the same color
    vars = variables(c)
    return [LocalConstraint([findfirst(==(c.sequence[i]), vars), findfirst(==(c.sequence[i+1]), vars)], (c.isfirst[i], c.isfirst[i+1])) for i=1:length(c.sequence)-1]
end

function local_energy(::Type{<:PaintShop{T}}, spec::LocalConstraint, config) where {T}
    @assert length(config) == num_variables(spec)
    isfirst1, isfirst2 = spec.specification
    c1, c2 = config
    return (c1 == c2) == (isfirst1 == isfirst2) ? zero(T) : one(T)
end

@nohard_constraints PaintShop

"""
    paint_shop_coloring_from_config(p::PaintShop, config)

Returns a valid painting from the paint shop configuration (given by the configuration solvers).
The `config` is a sequence of 0 and 1, where 0 means painting the first appearence of a car in red, 
and 1 means painting the first appearence of a car in blue.
"""
function paint_shop_coloring_from_config(p::PaintShop{LT}, config) where {LT}
    d = Dict{LT,Bool}(zip(variables(p), config))
    return map(1:length(p.sequence)) do i
        p.isfirst[i] ? d[p.sequence[i]] : ~d[p.sequence[i]]
    end
end