struct SATProblem <: AbstractProblem
    clauses
end
# ET is the boolean type
# `head` is the operator
# `args` are the arguments
struct BooleanExpr
    head::Symbol
    args::Vector{BooleanExpr}
    var::Int
    function BooleanExpr(i::Int)
        new(:var, BooleanExpr[], i)
    end
    function BooleanExpr(head::Symbol, args::Vector{BooleanExpr})
        new(head, args)
    end
end
function booleans(n::Int)
    return BooleanExpr.(1:n)
end
¬(x::BooleanExpr) = BooleanExpr(:¬, [x])
∧(x::BooleanExpr, ys::BooleanExpr...) = BooleanExpr(:∧, [x, ys...])
∨(x::BooleanExpr, ys::BooleanExpr...) = BooleanExpr(:∨, [x, ys...])
Base.:(⊻)(x::BooleanExpr, ys::BooleanExpr...) = BooleanExpr(:⊻, [x, ys...])
function Base.show(io::IO, x::BooleanExpr)
    if x.head == :var
        print(io, "#", x.var)
    else
        print(io, x.head, "(", join(x.args, ", "), ")")
    end
end
Base.show(io::IO, ::MIME"text/plain", x::BooleanExpr) = show(io, x)

is_var(x::BooleanExpr) = x.head == :var
is_literal(x::BooleanExpr) = x.head == :var || (x.head == :¬ && x.args[1].head == :var)
is_cnf(x::BooleanExpr) = x.head == :∧ && all(a->(a.head == :∨ && all(is_literal, a.args)), x.args)
is_dnf(x::BooleanExpr) = x.head == :∨ && all(a->(a.head == :∧ && all(is_literal, a.args)), x.args)

Base.:(==)(x::BooleanExpr, y::BooleanExpr) = x.head == y.head && x.var == y.var && all(x.args .== y.args)
Base.hash(x::BooleanExpr, h::UInt) = hash(x.head, hash(x.var, hash(x.args, h)))
function Base.eval(ex::BooleanExpr, dict::Dict{BooleanExpr, Bool})
    if ex.head == :var
        return dict[ex]
    else
        _eval(Val(ex.head), dict, Base.eval.(ex.args, Ref(dict))...)
    end
end
_eval(::Val{:¬}, dict, x) = !x
_eval(::Val{:∨}, dict, xs...) = any(xs)
_eval(::Val{:∧}, dict, xs...) = all(xs)
_eval(::Val{:⊻}, dict, xs...) = reduce(xor, xs)

function maximum_var(x::BooleanExpr)
    if x.head == :var
        return x.var
    else
        return maximum(maximum_var, x.args)
    end
end

function dnf(x::BooleanExpr)
    vars = staticbooleans(maximum_var(x))
    return dnf(x, vars)
end
function dnf(x::BooleanExpr, vars)
    if x.head == :∧
        return reduce(∧, map(DNF, x.args))
    elseif x.head == :∨
        return reduce(∨, map(DNF, x.args))
    elseif x.head == :¬
        return x
    else  # :var
        return vars[x.var]
    end
end

struct CircuitSAT <: AbstractProblem
    expr::BooleanExpr
end

struct DNFClause{N, C}
    mask::StaticBitVector{N, C}
    val::StaticBitVector{N, C}
end

Base.show(io::IO, c::DNFClause{N}) where{N} = print(io, "DNFClause($N, $(count_ones(c.mask))) \n mask = $(c.mask) \n val = $(c.val)")
function staticbooleans(n::Int)
    s = _nints(n, 1)
    return map(1:n) do i
        v = onehotv(StaticBitVector{n, s}, i)
        DNFClause(v, v)
    end
end
∧(x::DNFClause, xs::DNFClause...) = DNFClause(reduce(|, getfield.(xs, :mask); init=x.mask), reduce(|, getfield.(xs, :val); init=x.val))
¬(x::DNFClause) = Or(x.mask, flip(x.val, x.mask))
BitBasis.flip(x::StaticBitVector{N,S}, mask::StaticBitVector{N,S}) where {N,S} = StaticBitVector{N,S}(flip.(x.data, mask.data))