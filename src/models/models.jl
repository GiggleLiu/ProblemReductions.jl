"""
    AbstractProblem

The abstract base type of computational problems.

### Required interfaces
- [`num_variables`](@ref), the number of variables in the computational problem.
- [`num_flavors`](@ref), the number of flavors (domain) of a degree of freedom.
- [`solution_size`](@ref), the size (the lower the better) of the input configuration.
- [`problem_size`](@ref), the size of the computational problem. e.g. for a graph, it could be `(n_vertices=?, n_edges=?)`.
- [`energy_mode`](@ref), the definition of the energy function, which can be `LargerSizeIsBetter` or `SmallerSizeIsBetter`.

### Derived interfaces
- [`variables`](@ref), the degrees of freedoms in the computational problem.
- [`flavors`](@ref), the flavors (domain) of a degree of freedom.
- [`findbest`](@ref), find the best configurations of the input problem.
"""
abstract type AbstractProblem end

abstract type EnergyMode end

"""
    LargerSizeIsBetter <: EnergyMode

The energy is defined as the negative size of the solution, which is the larger size the lower energy.
"""
struct LargerSizeIsBetter <: EnergyMode end

"""
    SmallerSizeIsBetter <: EnergyMode

The energy is defined as the size of the solution, which is the smaller size the lower energy.
"""
struct SmallerSizeIsBetter <: EnergyMode end

"""
    ConstraintSatisfactionProblem{T} <: AbstractProblem

The abstract base type of constraint satisfaction problems. `T` is the type of the local size of the constraints.

### Required interfaces
- [`constraints`](@ref), the specification of the constraints. Once the constraints are violated, the size goes to infinity.
- [`objectives`](@ref), the specification of the size terms as soft constraints, which is associated with weights.

### Optional interfaces
- [`weights`](@ref): The weights of the soft constraints.
- [`set_weights`](@ref): Change the weights for the `problem` and return a new problem instance.

### Derived interfaces
- [`is_satisfied`](@ref), check if the constraints are satisfied.
"""
abstract type ConstraintSatisfactionProblem{T} <: AbstractProblem end

"""
$TYPEDEF

A constraint for specifying a [`ConstraintSatisfactionProblem`](@ref), which is defined on finite domain variables.

### Fields
- `num_flavors`: the number of flavors (domain) of a degree of freedom.
- `variables`: the indices of the variables involved in the constraint.
- `specification`: a boolean vector of length `num_flavors^length(variables)`, specifying whether a configuration is valid.
- `strides`: the strides of the variables, to index the specification vector.
"""
struct LocalConstraint
    num_flavors::Int
    variables::Vector{Int}
    specification::Vector{Bool}
    strides::Vector{Int}
end
function LocalConstraint(num_flavors::Int, variables::Vector{Int}, specification::Vector{Bool})
    strides = [num_flavors^i for i in 0:(length(variables)-1)]
    return LocalConstraint(num_flavors, variables, specification, strides)
end
num_variables(spec::LocalConstraint) = length(spec.variables)
function combinations(num_flavors::Int, num_variables::Int)
    strides = [num_flavors^i for i in 0:(num_variables-1)]
    return [mod.(i .÷ strides, num_flavors) for i in 0:(num_flavors^num_variables-1)]
end
function Base.show(io::IO, spec::LocalConstraint)
    print(io, "LocalConstraint on $(spec.variables)\n")
    data = hcat(collect(combinations(spec.num_flavors, length(spec.variables))), spec.specification)
    header = ["Configuration", "Valid"]
    pretty_table(io, data, header=header, alignment=:c)
end
Base.show(io::IO, ::MIME"text/plain", spec::LocalConstraint) = show(io, spec)
"""
    is_satisfied(constraint::LocalConstraint, config) -> Bool
    is_satisfied(problem::ConstraintSatisfactionProblem, config) -> Bool

Check if the `constraint` is satisfied by the configuration `config`.
"""
function is_satisfied(constraint::LocalConstraint, config)
    @assert length(config) == num_variables(constraint) "The length of the configuration must be equal to the number of variables in the constraint, got $(length(config)) and $(num_variables(constraint))"
    @assert all(x -> 0 <= x <= constraint.num_flavors-1, config) "The configuration must be a vector of integers in the range of 0 to $(constraint.num_flavors-1)"
    k = sum(stride * c for (stride, c, var) in zip(constraint.strides, config, constraint.variables)) + 1
    return constraint.specification[k]
end
function is_satisfied(problem::ConstraintSatisfactionProblem, config)
    return all(c->is_satisfied(c, config[c.variables]), constraints(problem))
end

"""
$TYPEDEF

Problem size defined on a subset of variables of a [`ConstraintSatisfactionProblem`](@ref).

### Fields
- `num_flavors`: the number of flavors (domain) of a degree of freedom.
- `variables`: the indices of the variables involved in the constraint.
- `specification`: a vector of size `num_flavors^length(variables)`, specifying the local solution sizes.
- `strides`: the strides of the variables, to index the specification vector.
"""
struct LocalSolutionSize{T}
    num_flavors::Int
    variables::Vector{Int}
    specification::Vector{T}
    strides::Vector{Int}
end
function LocalSolutionSize(num_flavors::Int, variables::Vector{Int}, specification::Vector{T}) where T
    strides = [num_flavors^i for i in 0:(length(variables)-1)]
    return LocalSolutionSize(num_flavors, variables, specification, strides)
end
num_variables(spec::LocalSolutionSize) = length(spec.variables)
function Base.show(io::IO, spec::LocalSolutionSize{T}) where T
    print(io, "LocalSolutionSize{$T} on $(spec.variables)\n")
    data = hcat(collect(combinations(spec.num_flavors, length(spec.variables))), spec.specification)
    header = ["Configuration", "Size"]
    pretty_table(io, data, header=header, alignment=:c)
end
Base.show(io::IO, ::MIME"text/plain", spec::LocalSolutionSize) = show(io, spec)
"""
    solution_size(spec::LocalSolutionSize{WT}, config) where {WT}

The local solution size of a local solution configuration.
"""
function solution_size(spec::LocalSolutionSize{WT}, config) where {WT}
    @assert length(config) == num_variables(spec) "The length of the configuration must be equal to the number of variables in the constraint, got $(length(config)) and $(num_variables(spec))"
    @assert all(x -> 0 <= x <= spec.num_flavors-1, config) "The configuration must be a vector of integers in the range of 0 to $(spec.num_flavors-1)"
    k = sum(stride * c for (stride, c, var) in zip(spec.strides, config, spec.variables)) + 1
    return spec.specification[k]
end

######## Interfaces for computational problems ##########
"""
    weights(problem::ConstraintSatisfactionProblem) -> Vector

The weights of the constraints in the problem.
"""
function weights end

"""
    set_weights(problem::ConstraintSatisfactionProblem, weights) -> ConstraintSatisfactionProblem

Change the weights for the `problem` and return a new problem instance.
"""
function set_weights end

"""
    is_weighted(problem::ConstraintSatisfactionProblem) -> Bool

Check if the problem is weighted. Returns `true` if the problem has non-unit weights.
"""
function is_weighted(problem::ConstraintSatisfactionProblem)
    hasmethod(weights, Tuple{typeof(problem)}) && !(weights(problem) isa UnitWeight)
end

"""
    problem_size(problem::AbstractProblem) -> NamedTuple

The size of the computational problem, which is problem dependent.
"""
function problem_size end

"""
    variables(problem::AbstractProblem) -> Vector

The degrees of freedoms in the computational problem. e.g. for the maximum independent set problems, they are the indices of vertices: 1, 2, 3...,
while for the max cut problem, they are the edges.
"""
variables(c::AbstractProblem) = 1:num_variables(c)

"""
    num_variables(problem::AbstractProblem) -> Int

The number of variables in the computational problem.
"""
function num_variables end

"""
    weight_type(problem::AbstractProblem) -> Type

The data type of the weights in the computational problem.
"""
weight_type(gp::AbstractProblem) = eltype(weights(gp))

"""
    flavors(::Type{<:AbstractProblem}) -> UnitRange
    flavors(::GT) where GT<:AbstractProblem -> UnitRange

Returns a vector of integers as the flavors (domain) of a degree of freedom.

!!! warning
    Flavors is defined a `0:num_flavors-1`. To access the previous version of the flavors, use [`flavor_names`](@ref).
"""
flavors(::Type{GT}) where GT<:AbstractProblem = ntuple(i -> i-1, num_flavors(GT))
flavors(::GT) where GT<:AbstractProblem = flavors(GT)

"""
    flavor_names(::Type{<:AbstractProblem}) -> Vector

Returns a vector as the names of the flavors (domain) of a degree of freedom.
It falls back to [`flavors`](@ref) if no method is defined.
Use `ProblemReductions.name2config` and `ProblemReductions.config2name` to convert between the names and the configuration.
"""
flavor_names(::Type{GT}) where GT<:AbstractProblem = collect(flavors(GT))
flavor_names(::GT) where GT<:AbstractProblem = flavor_names(GT)
"""
    name2config(problem::AbstractProblem, config)

Convert the names of the flavors to the configuration.
"""
function name2config(problem::AbstractProblem, config)
    @assert all(c -> c in flavor_names(problem), config) "The flavor must be one of the flavors $(flavor_names(problem)), got: $(config)"
    flvs = flavor_names(problem)
    map(c -> findfirst(==(c), flvs) - 1, config)
end

"""
    config2name(problem::AbstractProblem, config)

Convert the configuration to the names of the flavors.
"""
function config2name(problem::AbstractProblem, config)
    flvs = flavor_names(problem)
    map(c -> flvs[c + 1], config)
end

"""
    num_flavors(::Type{<:AbstractProblem}) -> Int
    num_flavors(::GT) where GT<:AbstractProblem -> Int

Returns the number of flavors (domain) of a degree of freedom.
"""
num_flavors(::GT) where GT<:AbstractProblem = num_flavors(GT)

"""
$TYPEDEF

The size of the problem given a configuration.

### Fields
- `size`: the size of the problem.
- `is_valid`: whether the configuration is valid.
"""
struct SolutionSize{T}
    size::T
    is_valid::Bool
end
function Base.:(+)(s1::SolutionSize, s2::SolutionSize)
    return SolutionSize(s1.size + s2.size, s1.is_valid && s2.is_valid)
end
Base.:(==)(s1::SolutionSize, s2::SolutionSize) = s1.size == s2.size && s1.is_valid == s2.is_valid
Base.isapprox(s1::SolutionSize, s2::SolutionSize; kwargs...) = isapprox(s1.size, s2.size; kwargs...) && s1.is_valid == s2.is_valid

"""
    solution_size(problem::AbstractProblem, config) -> SolutionSize

Size of the `problem` given the configuration `config`. If you have multiple configurations, use `ProblemReductions.solution_size_multiple` instead for better performance.
"""
function solution_size(problem::ConstraintSatisfactionProblem, config)
    return first(solution_size_multiple(problem, (config,)))
end

"""
    solution_size_multiple(problem::ConstraintSatisfactionProblem, configs) -> Vector{SolutionSize}

Size of the `problem` given multiple configurations.
"""
function solution_size_multiple(problem::ConstraintSatisfactionProblem{T}, configs) where T
    cons = constraints(problem)
    engs = objectives(problem)
    return map(configs) do config
        is_valid = all(term -> is_satisfied(term, config[term.variables]), cons)
        return SolutionSize(_size_eval(engs, config), is_valid)
    end
end

Base.@propagate_inbounds function _size_eval(terms::AbstractVector{LocalSolutionSize{WT}}, config) where WT
    return sum(terms; init=zero(WT)) do term
        idx = 1  # NOTE: this is faster than mapreduce, or sum. Do not change it back.
        for i in 1:length(term.variables)
            idx += term.strides[i] * config[term.variables[i]]
        end
        return term.specification[idx]
    end
end

"""
    findbest(problem::AbstractProblem, method) -> Vector

Find the best configurations of the `problem` using the `method`.
"""
function findbest end

"""
    UnitWeight <: AbstractVector{Int}

The unit weight vector of length `n`.
"""
struct UnitWeight <: AbstractVector{Int}
    n::Int
end
Base.getindex(::UnitWeight, i) = 1
Base.size(w::UnitWeight) = (w.n,)

"""
    objectives(problem::AbstractProblem) -> Vector{<:LocalSolutionSize}

The constraints related to the size of the problem. Each term is associated with weights.
"""
function objectives end

"""
    constraints(problem::AbstractProblem) -> Vector{LocalConstraint}

The constraints of the problem.
"""
function constraints end

macro noconstraints(problem)
    esc(quote
        function $ProblemReductions.constraints(problem::$(problem))
            return LocalConstraint[]
        end
    end)
end

@enum ObjectiveType SAT EXTREMA

"""
    energy_mode(problem::AbstractProblem) -> EnergyMode

The definition of the energy function, which can be [`LargerSizeIsBetter`](@ref) or [`SmallerSizeIsBetter`](@ref).
If will be used in the energy based modeling of the target problem.
"""
energy_mode(problem::AbstractProblem) = energy_mode(typeof(problem))

"""
    energy(problem::AbstractProblem, config) -> Number

The energy of the `problem` given the configuration `config`. Please check the [`energy_mode`](@ref) for the definition of the energy function.
"""
function energy(problem::AbstractProblem, config)
    s = solution_size(problem, config)
    return s.is_valid ? (energy_mode(problem) == LargerSizeIsBetter() ? -s.size : s.size) : energy_max(typeof(s.size))
end
# the maximum energy for the local energy function, this is used to avoid overflow of integer energy
energy_max(::Type{T}) where T = typemax(T)
energy_max(::Type{T}) where T<:Integer = round(T, sqrt(typemax(T)))

include("SpinGlass.jl")
include("Circuit.jl")
include("Coloring.jl")
include("Satisfiability.jl")
include("SetCovering.jl")
include("MaxCut.jl")
include("IndependentSet.jl")
include("VertexCovering.jl")
include("SetPacking.jl")
include("DominatingSet.jl")
include("QUBO.jl")
include("Factoring.jl")
include("Matching.jl")
include("MaximalIS.jl")
include("Paintshop.jl")
include("BMF.jl")
