"""
    AbstractProblem

The abstract base type of graph problems.
"""
abstract type AbstractProblem end

struct UnitWeight end
Base.getindex(::UnitWeight, i) = 1
Base.eltype(::UnitWeight) = Int

struct ZeroWeight end
Base.getindex(::ZeroWeight, i) = 0
Base.eltype(::ZeroWeight) = Int

######## Interfaces for graph problems ##########
"""
    get_weights(problem::AbstractProblem[, i::Int]) -> Vector

The weights for the `problem` or the weights for the degree of freedom specified by the `i`-th term if a second argument is provided.
Weights are associated with [`terms`](@ref) in the graph problem.
In graph polynomial, integer weights can be the exponents.
"""
function get_weights end
get_weights(c::AbstractProblem) = map(i->get_weights(c, i), 1:num_terms(c))

"""
    chweights(problem::AbstractProblem, weights) -> AbstractProblem

Change the weights for the `problem` and return a new problem instance.
Weights are associated with [`terms`](@ref) in the graph problem.
In graph polynomial, integer weights can be the exponents.
"""
function chweights end

"""
    variables(problem::AbstractProblem) -> Vector

The variables of a problem is defined as the degrees of freedoms in the graph problem.
e.g. for the maximum independent set problems, they are the indices of vertices: 1, 2, 3...,
while for the max cut problem, they are the edges.
"""
function variables end

"""
    num_variables(problem::AbstractProblem) -> Int

The number of variables in the graph problem.
"""
num_variables(c::AbstractProblem) = length(variables(c))

"""
    terms(problem::AbstractProblem) -> Vector

The energy terms of a graph problem is defined as the variables that carrying local energies (or weights) in the graph problem.
"""
function terms end

"""
    num_terms(problem::AbstractProblem) -> Int

The number of terms in the graph problem.
"""
num_terms(c::AbstractProblem) = length(terms(c))

"""
    local_energy(problem::AbstractProblem[, i::Int]) -> Vector

The local energy( of the `i`-th term) in the graph problem.
"""
function local_energy end
local_energy(c::AbstractProblem) = map(i->local_energy(c, i), 1:num_terms(c))

"""
    energy_type(problem::AbstractProblem) -> Type

The energy type of the graph problem.
"""
energy_type(gp::AbstractProblem) = eltype(eltype(get_weights(gp)))

"""
    flavors(::Type{<:AbstractProblem}) -> Vector

It returns a vector of integers as the flavors of a degree of freedom.
Its size is the same as the degree of freedom on a single vertex/edge.
"""
flavors(::GT) where GT<:AbstractProblem = flavors(GT)
num_flavors(::GT) where GT<:AbstractProblem = length(flavors(GT))

"""
    nflavor(::Type{<:AbstractProblem}) -> Int
    nflavor(::GT) where GT<:AbstractProblem -> Int

Bond size is equal to the number of flavors.
"""
nflavor(::Type{GT}) where GT = length(flavors(GT))
nflavor(::GT) where GT<:AbstractProblem = nflavor(GT)

include("SpinGlass.jl")