"""
    AbstractProblem

The abstract base type of computational problems.

### Required interfaces
- [`variables`](@ref), the degrees of freedoms in the computational problem.
- [`flavors`](@ref), the flavors (domain) of a degree of freedom.
- [`solution_size`](@ref), the size (the lower the better) of the input configuration.
- [`problem_size`](@ref), the size of the computational problem. e.g. for a graph, it could be `(n_vertices=?, n_edges=?)`.

### Optional interfaces
- [`num_variables`](@ref), the number of variables in the computational problem.
- [`num_flavors`](@ref), the number of flavors (domain) of a degree of freedom.
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
- [`hard_constraints`](@ref), the specification of the hard constraints. Once the hard constraints are violated, the size goes to infinity.
- [`is_satisfied`](@ref), check if the hard constraints are satisfied.

- [`local_solution_size`](@ref), the specification of the size terms as soft constraints, which is associated with weights.
- [`weights`](@ref): The weights of the soft constraints.
- [`set_weights`](@ref): Change the weights for the `problem` and return a new problem instance.
- [`solution_size`](@ref), the size of the problem given a configuration.
- [`energy_mode`](@ref), the definition of the energy function, which can be `LargerSizeIsBetter` or `SmallerSizeIsBetter`.
"""
abstract type ConstraintSatisfactionProblem{T} <: AbstractProblem end

"""
$TYPEDEF

A hard constraint for specifying a [`ConstraintSatisfactionProblem`](@ref), which is defined on finite domain variables.

### Fields
- `num_flavors`: the number of flavors (domain) of a degree of freedom.
- `variables`: the indices of the variables involved in the constraint.
- `specification`: a boolean vector of length `num_flavors^length(variables)`, specifying whether a configuration is valid.
"""
struct HardConstraint
    num_flavors::Int
    variables::Vector{Int}
    specification::Vector{Bool}
end
num_variables(spec::HardConstraint) = length(spec.variables)
function combinations(num_flavors::Int, num_variables::Int)
    strides = [num_flavors^i for i in 0:(num_variables-1)]
    return [mod.(i .÷ strides, num_flavors) for i in 0:(num_flavors^num_variables-1)]
end
function Base.show(io::IO, spec::HardConstraint)
    print(io, "HardConstraint\n")
    data = hcat(collect(combinations(spec.num_flavors, spec.num_variables)), spec.specification)
    header = ["Config", "Valid"]
    pretty_table(io, data, header=header, alignment=:c)
end
Base.show(io::IO, ::MIME"text/plain", spec::HardConstraint) = show(io, spec)
"""
    is_satisfied(constraint::HardConstraint, config) -> Bool

Check if the `constraint` is satisfied by the configuration `config`.
"""
function is_satisfied(constraint::HardConstraint, config)
    @assert length(config) == num_variables(constraint) "The length of the configuration must be equal to the number of variables in the constraint, got $(length(config)) and $(num_variables(constraint))"
    @assert all(x -> 0 <= x <= constraint.num_flavors-1, config) "The configuration must be a vector of integers in the range of 0 to $(constraint.num_flavors-1)"
    strides = [constraint.num_flavors^i for i in 0:length(constraint.variables)-1]
    k = sum(stride * c for (stride, c, var) in zip(strides, config, constraint.variables)) + 1
    return constraint.specification[k]
end

"""
$TYPEDEF

Problem size defined on a subset of variables of a [`ConstraintSatisfactionProblem`](@ref).

### Fields
- `num_flavors`: the number of flavors (domain) of a degree of freedom.
- `variables`: the indices of the variables involved in the constraint.
- `specification`: a vector of size `num_flavors^length(variables)`, specifying the local solution sizes.
"""
struct LocalSolutionSize{T}
    num_flavors::Int
    variables::Vector{Int}
    specification::Vector{T}
end
num_variables(spec::LocalSolutionSize) = length(spec.variables)
function Base.show(io::IO, spec::LocalSolutionSize{T}) where T
    print(io, "LocalSolutionSize{$T}\n")
    data = hcat(collect(combinations(spec.num_flavors, length(spec.variables))), spec.specification)
    header = ["Variables: $(spec.variables)", "Size"]
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
    strides = [spec.num_flavors^i for i in 0:length(spec.variables)-1]
    k = sum(stride * c for (stride, c, var) in zip(strides, config, spec.variables)) + 1
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
    flavor_to_logical(::Type{T}, flavor) -> T

Convert the flavor to a logical value.
"""
function flavor_to_logical(::Type{T}, flavor) where T
    flvs = flavors(T)
    @assert length(flvs) == 2 "The number of flavors must be 2, got: $(length(flvs))"
    if flavor == flvs[1]
        return false
    elseif flavor == flvs[2]
        return true
    else
        error("The flavor must be one of the flavors $(flvs), got: $(flavor)")
    end
end

"""
    num_flavors(::Type{<:AbstractProblem}) -> Int
    num_flavors(::GT) where GT<:AbstractProblem -> Int

Returns the number of flavors (domain) of a degree of freedom.
"""
num_flavors(::GT) where GT<:AbstractProblem = num_flavors(GT)
num_flavors(::Type{GT}) where GT<:AbstractProblem = length(flavors(GT))

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
    cons = hard_constraints(problem)
    engs = local_solution_size(problem)
    return map(configs) do config
        if _is_satisfied(cons, config)
            return SolutionSize(_size_eval(engs, config), true)
        else
            return SolutionSize(zero(T), false)
        end
    end
end
Base.@propagate_inbounds function _is_satisfied(terms::AbstractVector{HardConstraint}, config)
    return all(terms) do term
        is_satisfied(term, config[term.variables])
    end
end

Base.@propagate_inbounds function _size_eval(terms::AbstractVector{LocalSolutionSize{WT}}, config) where WT
    return sum(terms) do term
        strides = [term.num_flavors^i for i in 0:length(term.variables)-1]
        term.specification[sum(i->strides[i] .* config[term.variables[i]], 1:length(term.variables)) + 1]
    end
end

"""
$TYPEDSIGNATURES

Return the log2 size of the configuration space of the problem.
"""
function configuration_space_size(problem::AbstractProblem)
    return log2(num_flavors(problem)) * num_variables(problem)
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
    local_solution_size(problem::AbstractProblem) -> Vector{LocalSolutionSize}

The constraints related to the size of the problem. Each term is associated with weights.
"""
function local_solution_size end

"""
    hard_constraints(problem::AbstractProblem) -> Vector{HardConstraint}

The hard constraints of the problem.
"""
function hard_constraints end

macro nohard_constraints(problem)
    esc(quote
        function $ProblemReductions.hard_constraints(problem::$(problem))
            return HardConstraint[]
        end
    end)
end

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
