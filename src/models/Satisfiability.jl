"""
    BoolVar{T}
    BoolVar(name, neg)

Boolean variable for constructing CNF clauses.
"""
struct BoolVar{T}
    name::T
    neg::Bool
end
BoolVar(name) = BoolVar(name, false)
function Base.show(io::IO, b::BoolVar)
    b.neg && print(io, "¬")
    print(io, b.name)
end

"""
    CNFClause{T}
    CNFClause(vars)

A clause in [`CNF`](@ref), its value is the logical or of `vars`, where `vars` is a vector of [`BoolVar`](@ref).
"""
struct CNFClause{T}
    vars::Vector{BoolVar{T}}
end
function Base.show(io::IO, b::CNFClause)
    print(io, join(string.(b.vars), " ∨ "))
end
Base.:(==)(x::CNFClause, y::CNFClause) = x.vars == y.vars
Base.length(x::CNFClause) = length(x.vars)
symbols(clause::CNFClause) = unique([var.name for var in clause.vars])

"""
    CNF{T}
    CNF(clauses)

Boolean expression in [conjunctive normal form](https://en.wikipedia.org/wiki/Conjunctive_normal_form).
`clauses` is a vector of [`CNFClause`](@ref), if and only if all clauses are satisfied, this CNF is satisfied.

Example
------------------------
Under development
"""
struct CNF{T}
    clauses::Vector{CNFClause{T}}
end
function Base.show(io::IO, c::CNF)
    print(io, join(["($k)" for k in c.clauses], " ∧ "))
end
Base.:(==)(x::CNF, y::CNF) = x.clauses == y.clauses
Base.length(x::CNF) = length(x.clauses)

"""
    ¬(var::BoolVar)

Negation of a boolean variables of type [`BoolVar`](@ref).
"""
¬(var::BoolVar{T}) where T = BoolVar(var.name, ~var.neg)

"""
    ∨(vars...)

Logical `or` applied on [`BoolVar`](@ref) and [`CNFClause`](@ref).
Returns a [`CNFClause`](@ref).
"""
∨(var::BoolVar{T}, vars::BoolVar{T}...) where T = CNFClause([var, vars...])
∨(c::CNFClause{T}, var::BoolVar{T}) where T = CNFClause([c.vars..., var])
∨(c::CNFClause{T}, d::CNFClause{T}) where T = CNFClause([c.vars..., d.vars...])
∨(var::BoolVar{T}, c::CNFClause) where T = CNFClause([var, c.vars...])


"""
    ∧(vars...)

Logical `and` applied on [`CNFClause`](@ref) and [`CNF`](@ref).
Returns a new [`CNF`](@ref).
"""
∧(c::CNFClause{T}, cs::CNFClause{T}...) where T = CNF([c, cs...])
∧(c::CNFClause{T}, cs::CNF{T}) where T = CNF([c, cs.clauses...])
∧(cs::CNF{T}, c::CNFClause{T}) where T = CNF([cs.clauses..., c])
∧(cs::CNF{T}, ds::CNF{T}) where T = CNF([cs.clauses..., ds.clauses...])

"""
    @bools(syms::Symbol...)

Create some boolean variables of type [`BoolVar`](@ref) in current scope that can be used in create a [`CNF`](@ref).

Example
------------------------
Under Development
"""
macro bools(syms::Symbol...)
    esc(Expr(:block, [:($s = $BoolVar($(QuoteNode(s)))) for s in syms]..., nothing))
end

function symbols(cnf::CNF{T}) where T
    unique([var.name for clause in cnf.clauses for var in clause.vars])
end

abstract type AbstractSatisfiabilityProblem{S, T} <: ConstraintSatisfactionProblem{T} end

"""
$TYPEDEF

Satisfiability (also called SAT) problem is to find the boolean assignment that satisfies a Conjunctive Normal Form (CNF). A tipical CNF would look like:
```math
\\left(l_{11} \\vee \\ldots \\vee l_{1 n_1}\\right) \\wedge \\ldots \\wedge\\left(l_{m 1} \\vee \\ldots \\vee l_{m n_m}\\right)
```
where literals are joint by ``\\vee`` to for ``m`` clauses and clauses are joint by ``\\wedge`` to form a CNF.

We should note that all the SAT problem problem can be reduced to the 3-SAT problem and it can be proved that 3-SAT is NP-complete.

Fields
-------------------------------
- `cnf` is a conjunctive normal form ([`CNF`](@ref)) for specifying the satisfiability problems.
- `weights` are associated with clauses.

Example
-------------------------------
In the following example, we define a satisfiability problem with two clauses.
```jldoctest
julia> using ProblemReductions

julia> bv1, bv2, bv3 = BoolVar.(["x", "y", "z"])
3-element Vector{BoolVar{String}}:
 x
 y
 z

julia> clause1 = CNFClause([bv1, bv2, bv3])
x ∨ y ∨ z

julia> clause2 = CNFClause([BoolVar("w"), bv1, BoolVar("x", true)])
w ∨ x ∨ ¬x

julia> cnf_test = CNF([clause1, clause2])
(x ∨ y ∨ z) ∧ (w ∨ x ∨ ¬x)

julia> sat_test = Satisfiability(cnf_test)
Satisfiability{String, Int64, UnitWeight}(["x", "y", "z", "w"], [1, 1], (x ∨ y ∨ z) ∧ (w ∨ x ∨ ¬x))
```
"""
struct Satisfiability{S, T, WT<:AbstractArray{T}} <:AbstractSatisfiabilityProblem{S, T}
    variables::Vector{S}
    weights::WT
    cnf::CNF{S}
    function Satisfiability(variables::Vector{S}, cnf::CNF{S}, weights::WT) where {S, T, WT<:AbstractArray{T}}
        @assert length(weights) == length(cnf.clauses) "length of weights must be equal to the number of clauses $(length(cnf.clauses)), got: $(length(weights))"
        new{S, T, WT}(variables, weights, cnf)
    end
end
function Satisfiability(cnf::CNF{S}, weights::AbstractVector=UnitWeight(length(cnf.clauses))) where {S}
    Satisfiability(symbols(cnf), cnf, weights)
end
clauses(c::Satisfiability) = c.cnf.clauses
num_variables(c::Satisfiability) = length(c.variables)
Base.:(==)(x::Satisfiability, y::Satisfiability) = x.cnf == y.cnf && x.weights == y.weights && x.variables == y.variables

weights(c::Satisfiability) = c.weights
set_weights(c::Satisfiability, weights::AbstractVector) = Satisfiability(c.variables, c.cnf, weights)

"""
$TYPEDEF

The satisfiability problem for k-SAT, where the goal is to find an assignment that satisfies the CNF.

### Fields
- `variables::Vector{T}`: The variables in the CNF.
- `cnf::CNF{T}`: The CNF expression.
"""
struct KSatisfiability{K, S, T, WT<:AbstractArray{T}} <:AbstractSatisfiabilityProblem{S, T}
    variables::Vector{S}
    cnf::CNF{S}
    weights::WT
    function KSatisfiability{K}(variables::Vector{S}, cnf::CNF{S}, weights::WT) where {K, S, T, WT<:AbstractVector{T}}
        @assert is_kSAT(cnf, K) "The CNF is not a $K-SAT problem"
        new{K, S, T, WT}(variables, cnf, weights)
    end
end
function KSatisfiability{K}(cnf::CNF{S}, weights::WT=UnitWeight(length(cnf.clauses))) where {K, S, WT<:AbstractVector}
    KSatisfiability{K}(symbols(cnf), cnf, weights)
end
Base.:(==)(x::KSatisfiability, y::KSatisfiability) = x.cnf == y.cnf
is_kSAT(cnf::CNF, k::Int) = all(c -> k == length(c.vars), cnf.clauses)
clauses(c::KSatisfiability) = c.cnf.clauses
num_variables(c::KSatisfiability) = length(c.variables)

problem_size(c::AbstractSatisfiabilityProblem) = (; num_claues = length(clauses(c)), num_variables = num_variables(c))
flavors(::Type{<:AbstractSatisfiabilityProblem}) = [0, 1]  # false, true

weights(c::KSatisfiability) = c.weights
set_weights(c::KSatisfiability, weights::Vector{WT}) where {WT} = KSatisfiability(c.variables, c.cnf, weights)

# constraints interface
function energy_terms(c::AbstractSatisfiabilityProblem)
    vars = symbols(c)
    return map(clauses(c)) do cl
        idx = [findfirst(==(v), vars) for v in symbols(cl)]
        LocalConstraint(idx, vars[idx] => cl)
    end
end
function local_energy(::Type{<:AbstractSatisfiabilityProblem{S, T}}, spec::LocalConstraint, config) where {S, T}
    @assert length(config) == num_variables(spec)
    vars, expr = spec.specification
    assignment = Dict(zip(vars, config))
    return !satisfiable(expr, assignment) ? one(T) : zero(T)
end

@nohard_constraints AbstractSatisfiabilityProblem

"""
    satisfiable(expr, config::AbstractDict{T}) where T

Check if the boolean expression `expr` is satisfied by the configuration `config`.
"""
function satisfiable(v::BoolVar{T}, config::AbstractDict{T}) where T
    config[v.name] == ~v.neg
end

function satisfiable(c::CNFClause{T}, config::AbstractDict{T}) where T
    any(v -> satisfiable(v, config), c.vars)
end

function satisfiable(cnf::CNF{T}, config::AbstractDict{T}) where T
    all(c -> satisfiable(c, config), cnf.clauses)
end