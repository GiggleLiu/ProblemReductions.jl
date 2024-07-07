struct BooleanExpr
    head::Symbol
    args::Vector{BooleanExpr}
    var::Symbol
    function BooleanExpr(i::Symbol)
        new(:var, BooleanExpr[], i)
    end
    function BooleanExpr(head::Symbol, args::Vector{BooleanExpr})
        new(head, args)
    end
end
function booleans(n::Int)
    return BooleanExpr.(Symbol.(1:n))
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

# ---------------------------------------

struct Assignment
    outputs::Vector{Symbol}
    expr::BooleanExpr
end
struct Circuit
    exprs::Vector{Assignment}
end

macro circuit(ex)
    analyse_circuit(ex)
end

function analyse_circuit(ex)
    @match ex begin
        :($var = $bex) => begin
        end
    end
end

function analyse_circuit(bex)
    @match bex begin
        :($f($(args...))) => BooleanExpr(f, analyse_circuit.(args))
        ::Symbol => BooleanExpr(bex)
    end
end