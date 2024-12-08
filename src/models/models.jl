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
    SmallerSizeIsBetter <: EnergyMode

The energy is defined as the negative size of the solution, which is the larger size the smaller lower nergy.
"""
struct LargerSizeIsBetter <: EnergyMode end
"""
    SmallerSizeIsBetter <: EnergyMode

The energy is defined as the size of the solution, which is the smaller size the smaller energy.
"""
struct SmallerSizeIsBetter <: EnergyMode end

"""
    ConstraintSatisfactionProblem{T} <: AbstractProblem

The abstract base type of constraint satisfaction problems. `T` is the type of the local size of the constraints.

### Required interfaces
- [`hard_constraints`](@ref), the specification of the hard constraints. Once the hard constraints are violated, the size goes to infinity.
- [`is_satisfied`](@ref), check if the hard constraints are satisfied.

- [`local_solution_spec`](@ref), the specification of the size terms as soft constraints, which is associated with weights.
- [`weights`](@ref): The weights of the soft constraints.
- [`set_weights`](@ref): Change the weights for the `problem` and return a new problem instance.
- [`solution_size`](@ref), the size of the problem given a configuration.
- [`energy_mode`](@ref), the definition of the energy function, which can be `LargerSizeIsBetter` or `SmallerSizeIsBetter`.
"""
abstract type ConstraintSatisfactionProblem{T} <: AbstractProblem end

"""
$TYPEDEF

A hard constraint on a [`ConstraintSatisfactionProblem`](@ref).

### Fields
- `variables`: the indices of the variables involved in the constraint.
- `specification`: the specification of the constraint.
"""
struct HardConstraint{ST}
    variables::Vector{Int}
    specification::ST
end
num_variables(spec::HardConstraint) = length(spec.variables)

"""
$TYPEDEF

A soft constraint on a [`ConstraintSatisfactionProblem`](@ref).

### Fields
- `variables`: the indices of the variables involved in the constraint.
- `specification`: the specification of the constraint.
- `weight`:  the weight of the constraint.
"""
struct LocalSolutionSpec{WT, ST}
    variables::Vector{Int}
    specification::ST
    weight::WT
end
num_variables(spec::LocalSolutionSpec) = length(spec.variables)

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
    flavors(::Type{<:AbstractProblem}) -> Vector

Returns a vector of integers as the flavors (domain) of a degree of freedom.
"""
flavors(::GT) where GT<:AbstractProblem = flavors(GT)


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

Size of the `problem` given the configuration `config`.
"""
function solution_size end

# size interface
solution_size(problem::AbstractProblem, config) = first(solution_size_byid(problem, (config_to_id(problem, config),)))
function solution_size_byid(problem::ConstraintSatisfactionProblem{T}, ids) where T
    terms = size_terms(problem)
    return Iterators.map(ids) do id
        size_eval_byid(terms, id)
    end
end
function config_to_id(problem::AbstractProblem, config)
    flvs = flavors(problem)
    map(c -> findfirst(==(c), flvs), config)
end
function id_to_config(problem::AbstractProblem, id)
    flvs = flavors(problem)
    map(i -> flvs[i], id)
end

struct LocalSize{LT, N, F, T}
    variables::Vector{LT}
    flavors::NTuple{N, F}
    strides::Vector{Int}
    solution_sizes::Vector{SolutionSize{T}}
end
function Base.show(io::IO, term::LocalSize)
    println(io, """LocalSize""")
    entries = []
    sizes = repeat([length(term.flavors)], length(term.variables))
    for (idx, size) in zip(CartesianIndices(Tuple(sizes)), term.solution_sizes)
        push!(entries, [getindex.(Ref(term.flavors), idx.I)..., size.is_valid ? "$(size.size)" : "-"])
    end
	pretty_table(io, vcat([reshape(row, 1, :) for row in entries]...); header=[string.(term.variables)..., "solution size"])
	return nothing
end
Base.show(io::IO, ::MIME"text/plain", term::LocalSize) = show(io, term)

size_terms(problem::ConstraintSatisfactionProblem{T}) where T = size_terms(T, problem)
function size_terms(::Type{T}, problem::ConstraintSatisfactionProblem) where T
    vars = variables(problem)
    flvs = flavors(problem)
    nflv = length(flvs)
    terms = LocalSize{eltype(vars), length(flvs), eltype(flvs), T}[]
    for constraint in hard_constraints(problem)
        sizes = [nflv for _ in constraint.variables]
        solution_sizes = map(CartesianIndices(Tuple(sizes))) do idx
            SolutionSize(zero(T), is_satisfied(typeof(problem), constraint, getindex.(Ref(flvs), idx.I)))
        end
        strides = [nflv^i for i in 0:length(constraint.variables)-1]
        push!(terms, LocalSize(constraint.variables, flvs, strides, vec(solution_sizes)))
    end
    for (i, constraint) in enumerate(local_solution_spec(problem))
        sizes = [nflv for _ in constraint.variables]
        solution_sizes = map(CartesianIndices(Tuple(sizes))) do idx
            SolutionSize(T(solution_size(typeof(problem), constraint, getindex.(Ref(flvs), idx.I))), true)
        end
        strides = [nflv^i for i in 0:length(constraint.variables)-1]
        push!(terms, LocalSize(constraint.variables, flvs, strides, vec(solution_sizes)))
    end
    return terms
end

Base.@propagate_inbounds function size_eval_byid(terms::AbstractVector{<:LocalSize}, config_id)
    sum(terms) do term
        k = 1
        for (stride, var) in zip(term.strides, term.variables)
            k += stride * (config_id[var]-1)
        end
        term.solution_sizes[k]
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
    local_solution_spec(problem::AbstractProblem) -> Vector{LocalSolutionSpec}

The constraints related to the size of the problem. Each term is associated with weights.
"""
function local_solution_spec end

"""
    hard_constraints(problem::AbstractProblem) -> Vector{HardConstraint}

The hard constraints of the problem.
"""
function hard_constraints end

macro nohard_constraints(problem)
    esc(quote
        function $ProblemReductions.hard_constraints(problem::$(problem))
            return HardConstraint{Nothing}[]
        end
    end)
end

"""
    is_satisfied(::Type{<:ConstraintSatisfactionProblem}, constraint::HardConstraint, config) -> Bool

Check if the `constraint` is satisfied by the configuration `config`.
"""
function is_satisfied end

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
    energy_mode(problem) == LargerSizeIsBetter() ? -solution_size(problem, config).size : solution_size(problem, config).size
end

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
