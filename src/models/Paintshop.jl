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

julia> solution_size(problem, [0, 1, 0])
SolutionSize{Int64}(4, true)

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
num_flavors(::Type{<:PaintShop}) = 2
problem_size(c::PaintShop) = (; sequence_length=length(c.sequence))
Base.:(==)(a::PaintShop, b::PaintShop) = a.sequence == b.sequence && a.isfirst == b.isfirst

# constraints interface
function local_solution_size(c::PaintShop{T}) where T
    # constraints on alphabets with the same color
    syms = symbols(c)
    return map(1:length(c.sequence)-1) do i
        a, b = findfirst(==(c.sequence[i]), syms), findfirst(==(c.sequence[i+1]), syms)
        LocalSolutionSize(num_flavors(c), [a, b], [_paintshop_constraint(c.isfirst[i], c.isfirst[i+1], config) for config in combinations(num_flavors(c), 2)])
    end
end

# config is a boolean vector, false for red, true for blue
function _paintshop_constraint(isfirst1, isfirst2, config)
    c1, c2 = config
    return (c1 == c2) == (isfirst1 == isfirst2) ? false : true
end
energy_mode(::Type{<:PaintShop}) = SmallerSizeIsBetter()

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

"""
    num_paint_shop_color_switch(sequence::AbstractVector, coloring)

Returns the number of color switches.
"""
function num_paint_shop_color_switch(sequence::AbstractVector, coloring)
    return count(i->coloring[i] != coloring[i+1], 1:length(sequence)-1)
end
