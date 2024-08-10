"""
Basic useful functions for Boolean algebra (https://github.com/QuEraComputing/GenericTensorNetworks.jl/blob/master/src/networks/Satisfiability.jl)
"""

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

abstract type AbstractSatisfiabilityProblem <: AbstractProblem end

"""
$TYPEDEF

The [satisfiability](https://queracomputing.github.io/GenericTensorNetworks.jl/dev/generated/Satisfiability/) problem.

### Fields
* `cnf` is a conjunctive normal form ([`CNF`](@ref)) for specifying the satisfiability problems.
* `weights` are associated with clauses.
"""
struct Satisfiability{T} <:AbstractSatisfiabilityProblem
    variables::Vector{T}
    cnf::CNF{T}
    function Satisfiability(cnf::CNF{T}) where {T}
        # get all variables
        var_names = T[]
        for clause in cnf.clauses
            for var in clause.vars
                push!(var_names, var.name)
            end
        end
        new{T}(unique!(var_names), cnf)
    end
end
clauses(c::Satisfiability) = c.cnf.clauses
variables(c::Satisfiability) = c.variables

"""
$TYPEDEF

The satisfiability problem for k-SAT, where the goal is to find an assignment that satisfies the CNF.

### Fields
- `variables::Vector{T}`: The variables in the CNF.
- `cnf::CNF{T}`: The CNF expression.
"""
struct KSatisfiability{K, T} <:AbstractSatisfiabilityProblem
    variables::Vector{T}
    cnf::CNF{T}
    function KSatisfiability{K}(cnf::CNF{T}) where {K, T}
        @assert is_kSAT(cnf, K) "The CNF is not a $K-SAT problem"
        new{K, T}(unique([var.name for clause in cnf.clauses for var in clause.vars]), cnf)
    end
end
is_kSAT(cnf::CNF, k::Int) = all(c -> k == length(c.vars), cnf.clauses)
clauses(c::KSatisfiability) = c.cnf.clauses
variables(c::KSatisfiability) = c.variables

"""
problem size of the satisfiability problem is the number of clauses in the CNF.
"""
problem_size(c::AbstractSatisfiabilityProblem) = length(clauses(c))
flavors(::Type{<:AbstractSatisfiabilityProblem}) = [0, 1]  # false, true

function evaluate(c::AbstractSatisfiabilityProblem, config)
    @assert length(config) == num_variables(c)
    dict = Dict(zip(variables(c), config))
    count(x->!satisfiable(x, dict), clauses(c))
end

"""
    satisfiable(cnf::CNF, config::AbstractDict)

Returns true if an assignment of variables satisfies a [`CNF`](@ref).
"""
function satisfiable(cnf::CNF{T}, config::AbstractDict{T}) where T
    all(x->satisfiable(x, config), cnf.clauses)
end
function satisfiable(c::CNFClause{T}, config::AbstractDict{T}) where T
    any(x->satisfiable(x, config), c.vars)
end
function satisfiable(v::BoolVar{T}, config::AbstractDict{T}) where T
    config[v.name] == ~v.neg
end
