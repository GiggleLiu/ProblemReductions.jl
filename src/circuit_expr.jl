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
        print(io, x.var)
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
function evaluate(ex::BooleanExpr, dict::Dict{Symbol, Bool})
    if ex.head == :var
        return dict[ex.var]
    else
        _eval(Val(ex.head), dict, evaluate.(ex.args, Ref(dict))...)
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

function Base.show(io::IO, x::Circuit)
    for i in 1:length(x.exprs)
        ex = x.exprs[i]
        print(io, ex)
        i < length(x.exprs) && println(io)
    end
end
Base.show(io::IO, ::MIME"text/plain", x::Circuit) = show(io, x)
Base.show(io::IO, x::Assignment) = print(io, join(string.(x.outputs), ", "), " = ", x.expr)
Base.show(io::IO, ::MIME"text/plain", x::Assignment) = show(io, x)

function evaluate(c::Circuit, dict::Dict{Symbol, Bool})
    evaluate!(c.exprs, copy(dict))
end
function evaluate!(exprs::Vector{Assignment}, dict::Dict{Symbol, Bool})
    for ex in exprs
        for o in ex.outputs
            dict[o] = evaluate(ex.expr, dict)
        end
    end
    return dict
end

macro circuit(ex)
    analyse_circuit(ex)
end

function analyse_circuit(ex)
    @match ex begin
        :(begin $(exs...) end) => Circuit(analyse_circuit.(filter(x->!(x isa LineNumberNode), exs)))
        :($(vars...) = $bex) => Assignment(Symbol[vars...], analyse_expr(bex))
        _ => error("Invalid circuit expression: $ex")
    end
end

function analyse_expr(bex)
    @match bex begin
        :($f($(args...))) => BooleanExpr(f, analyse_expr.(args))
        ::Symbol => BooleanExpr(bex)
    end
end