"""
$TYPEDEF

The binary paint shop problem is defined as follows:
we are given a ``2m`` length sequence containing ``m`` cars, where each car appears twice.
Each car need to be colored red in one occurrence, and blue in the other.
We need to choose which occurrence for each car to color with which color — the goal is to minimize the number of times we need to change the current color.

Fields
-------------------------------
- `sequence` is a vector of symbols, each symbol is associated with a color.
- `isfirst` is a vector of boolean numbers, indicating whether the symbol is the first appearance in the sequence.

Example
-------------------------------
In the following example, we define a paint shop problem with 6 cars.
```jldoctest
julia> using ProblemReductions

julia> problem = PaintShop(["a","b","a","c","c","b"])
PaintShop{String}(["a", "b", "a", "c", "c", "b"], Bool[1, 1, 0, 1, 0, 0])

julia> num_variables(problem)
3

julia> flavors(problem)
(0, 1)

julia> energy(problem, [0, 1, 0])
4

julia> findbest(problem, BruteForce())
2-element Vector{Vector{Int64}}:
 [1, 0, 0]
 [0, 1, 1]
```
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

num_variables(gp::PaintShop) = length(gp.sequence) ÷ 2
symbols(gp::PaintShop) = unique(gp.sequence)
flavors(::Type{<:PaintShop}) = (0, 1)
problem_size(c::PaintShop) = (; sequence_length=length(c.sequence))
Base.:(==)(a::PaintShop, b::PaintShop) = a.sequence == b.sequence && a.isfirst == b.isfirst

# constraints interface
function energy_terms(c::PaintShop)
    # constraints on alphabets with the same color
    syms = symbols(c)
    return [SoftConstraint([findfirst(==(c.sequence[i]), syms), findfirst(==(c.sequence[i+1]), syms)], (c.isfirst[i], c.isfirst[i+1]), 1) for i=1:length(c.sequence)-1]
end

function local_energy(::Type{<:PaintShop}, spec::SoftConstraint{WT}, config) where {WT}
    @assert length(config) == num_variables(spec)
    isfirst1, isfirst2 = spec.specification
    c1, c2 = config
    return (c1 == c2) == (isfirst1 == isfirst2) ? zero(WT) : spec.weight
end

@nohard_constraints PaintShop

"""
    paint_shop_coloring_from_config(p::PaintShop, config)

Returns a valid painting from the paint shop configuration (given by the configuration solvers).
The `config` is a sequence of 0 and 1, where 0 means painting the first appearence of a car in red, 
and 1 means painting the first appearence of a car in blue.
"""
function paint_shop_coloring_from_config(p::PaintShop{LT}, config) where {LT}
    d = Dict{LT,Bool}(zip(symbols(p), config))
    return map(1:length(p.sequence)) do i
        p.isfirst[i] ? d[p.sequence[i]] : ~d[p.sequence[i]]
    end
end