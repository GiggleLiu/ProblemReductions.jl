"""
    AbstractProblem

The abstract base type of computational problems.

### Required interfaces
- [`variables`](@ref), the degrees of freedoms in the computational problem.
- [`flavors`](@ref), the flavors (domain) of a degree of freedom.
- [`energy`](@ref), energy the energy (the lower the better) of the input configuration.
- [`problem_size`](@ref), the size of the computational problem. e.g. for a graph, it could be `(n_vertices=?, n_edges=?)`.

### Optional interfaces
- [`num_variables`](@ref), the number of variables in the computational problem.
- [`num_flavors`](@ref), the number of flavors (domain) of a degree of freedom.
- [`findbest`](@ref), find the best configurations of the input problem.
"""
abstract type AbstractProblem end

"""
    ConstraintSatisfactionProblem{T} <: AbstractProblem

The abstract base type of constraint satisfaction problems. `T` is the type of the local energy of the constraints.

### Required interfaces
- [`energy_terms`](@ref), the specification of the energy terms, it is associated with weights.
- [`hard_constraints`](@ref), the specification of the hard constraints. Once the hard constraints are violated, the energy goes to infinity.
- [`local_energy`](@ref), the local energy for the constraints.
"""
abstract type ConstraintSatisfactionProblem{T} <: AbstractProblem end

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
function variables end

"""
    num_variables(problem::AbstractProblem) -> Int

The number of variables in the computational problem.
"""
num_variables(c::AbstractProblem) = length(variables(c))

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

Returns the number of flavors (domain) of a degree of freedom.
"""
num_flavors(::GT) where GT<:AbstractProblem = length(flavors(GT))

"""
    energy(problem::AbstractProblem, config) -> Real

Energy of the `problem` given the configuration `config`.
The lower the energy, the better the configuration.
"""
function energy end

# energy interface
function energy(problem::ConstraintSatisfactionProblem{T}, config) where T
    @assert length(config) == num_variables(problem)
    hard_specs = hard_constraints(problem)
    for spec in hard_specs
        is_satisfied(typeof(problem), spec, config[spec.variables]) || return energy_max(T)
    end
    terms = energy_terms(problem)
    ws = is_weighted(problem) ? weights(problem) : UnitWeight(length(terms))
    @assert length(ws) == length(terms) "The length of the weights must be the same as the number of energy terms, got: $(length(ws)) != $(length(terms))"
    return sum(zip(terms, ws)) do (spec, weight)
        subconfig = config[spec.variables]
        local_energy(typeof(problem), spec, subconfig) * weight
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

# returns a n-dimensional array.
configuration_space(p::AbstractProblem, n::Int) = Iterators.product(fill(flavors(p), n)...)

"""
$TYPEDEF

The local constraint of the problem.

### Fields
- `variables`: the indices of the variables involved in the constraint.
- `specification`: the specification of the constraint.
"""
struct LocalConstraint{ST}
    variables::Vector{Int}
    specification::ST
end
num_variables(spec::LocalConstraint) = length(spec.variables)

"""
    energy_terms(problem::AbstractProblem) -> Vector{LocalConstraint}

The energy terms of the problem. Each term is associated with weights.
"""
function energy_terms end

"""
    hard_constraints(problem::AbstractProblem) -> Vector{LocalConstraint}

The hard constraints of the problem. Once the hard constraints are violated, the energy goes to infinity.
"""
function hard_constraints end

macro nohard_constraints(problem)
    esc(quote
        function $ProblemReductions.hard_constraints(problem::$(problem))
            return LocalConstraint{Nothing}[]
        end
    end)
end

"""
    local_energy(::Type{<:ConstraintSatisfactionProblem{T}}, constraint::LocalConstraint, config) -> T

The local energy of the `constraint` given the configuration `config`.
"""
function local_energy end

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
