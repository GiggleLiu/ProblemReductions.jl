"""
    AbstractProblem

The abstract base type of graph problems.
"""
abstract type AbstractProblem end

######## Interfaces for graph problems ##########
"""
    get_weights(problem::AbstractProblem[, i::Int]) -> Vector

Energies associated with [`terms`](@ref). Returns the weights for the `i`-th term if a second argument is provided.
"""
function get_weights end
get_weights(c::AbstractProblem) = map(i->get_weights(c, i), 1:num_terms(c))

"""
    chweights(problem::AbstractProblem, weights) -> AbstractProblem

Change the weights for the `problem` and return a new problem instance.
"""
function chweights end

"""
    variables(problem::AbstractProblem) -> Vector

The degrees of freedoms in the graph problem. e.g. for the maximum independent set problems, they are the indices of vertices: 1, 2, 3...,
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
    weight_type(problem::AbstractProblem) -> Type

The data type of the weights in the graph problem.
"""
weight_type(gp::AbstractProblem) = eltype(eltype(get_weights(gp)))

"""
    flavors(::Type{<:AbstractProblem}) -> Vector

Returns a vector of integers as the flavors (domain) of a degree of freedom.
"""
flavors(::GT) where GT<:AbstractProblem = flavors(GT)

"""
    num_flavors(::Type{<:AbstractProblem}) -> Int

Returns the number of flavors (domain) of a degree of freedom.
"""
num_flavors(::GT) where GT<:AbstractProblem = length(flavors(GT))

include("SpinGlass.jl")
include("Circuit.jl")