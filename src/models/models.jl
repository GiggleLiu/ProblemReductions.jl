"""
    AbstractProblem

The abstract base type of graph problems.
"""
abstract type AbstractProblem end

######## Interfaces for graph problems ##########
"""
    parameters(problem::AbstractProblem) -> Vector

Parameters associated with [`terms`](@ref).
"""
function parameters end

"""
    set_parameters(problem::AbstractProblem, parameters) -> AbstractProblem

Change the parameters for the `problem` and return a new problem instance.
"""
function set_parameters end

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
    parameter_type(problem::AbstractProblem) -> Type

The data type of the parameters in the graph problem.
"""
parameter_type(gp::AbstractProblem) = eltype(parameters(gp))

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

"""
    evaluate(problem::AbstractProblem, config) -> Real

Evaluate the energy of the `problem` given the configuration `config`.
The lower the energy, the better the configuration.
"""
function evaluate end

"""
    findbest(problem::AbstractProblem, method) -> Vector

Find the best configurations of the `problem` using the `method`.
"""
function findbest end

include("SpinGlass.jl")
include("Circuit.jl")