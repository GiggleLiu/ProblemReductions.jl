"""
$TYPEDEF

The [binary paint shop problem](https://queracomputing.github.io/GenericTensorNetworks.jl/dev/generated/PaintShop/).

Positional arguments
-------------------------------
* `sequence` is a vector of symbols, each symbol is associated with a color.
* `isfirst` is a vector of boolean numbers, indicating whether the symbol is the first appearance in the sequence.
"""
struct PaintShop{LT} <: AbstractProblem
    sequence::Vector{LT}
    isfirst::Vector{Bool}
    function PaintShop(sequence::AbstractVector{T}) where T
        @assert all(l->count(==(l), sequence)==2, sequence)
        n = length(sequence)
        isfirst = [findfirst(==(sequence[i]), sequence) == i for i=1:n]
        new{eltype(sequence)}(sequence, isfirst)
    end
end
Base.:(==)(a::PaintShop, b::PaintShop) = a.sequence == b.sequence && a.isfirst == b.isfirst


variables(gp::PaintShop) = unique(gp.sequence)
flavors(::Type{<:PaintShop}) = [0, 1]

# weights interface  ?We need that?

"""
    evaluate(ps::PaintShop, config) 

Returns the number of color switches.
For example, if the sequence is `abaccb` ,there are three variables, then the config should be [1,0,1] or [0,1,0].
Here [1,0,1] means you want the first color for `a` and `c` is red, and the first color for `b` is blue.
"""
function evaluate(ps::PaintShop,config)
    @assert length(config) == length(unique(ps.sequence)) "The length of the configuration should be equal to the length of the sequence."
    coloring = paint_shop_coloring_from_config(ps, config)
    return count(i->coloring[i] != coloring[i+1], 1:length(ps.sequence)-1)
end

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