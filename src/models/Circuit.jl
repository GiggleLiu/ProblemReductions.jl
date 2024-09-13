struct BooleanExpr
    head::Symbol
    args::Vector{BooleanExpr}
    var::Symbol
    function BooleanExpr(i::Symbol)
        new(:var, BooleanExpr[], i)
    end
    function BooleanExpr(b::Bool)
        new(:var, BooleanExpr[], b ? Symbol("true") : Symbol("false"))
    end
    function BooleanExpr(head::Symbol, args::Vector{BooleanExpr})
        @assert head != :var
        new(head, args)
    end
end
function extract_symbols!(ex::BooleanExpr, vars::Vector{Symbol})
    if ex.head == :var
        (ex.var == Symbol("true") || ex.var == Symbol("false")) && return
        push!(vars, ex.var)
    else
        map(v->extract_symbols!(v, vars), ex.args)
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

is_var(x::BooleanExpr) = x.head == :var && !(x.var == Symbol("true") || x.var == Symbol("false"))
is_literal(x::BooleanExpr) = x.head == :var || (x.head == :¬ && x.args[1].head == :var)
is_cnf(x::BooleanExpr) = x.head == :∧ && all(a->(a.head == :∨ && all(is_literal, a.args)), x.args)
is_dnf(x::BooleanExpr) = x.head == :∨ && all(a->(a.head == :∧ && all(is_literal, a.args)), x.args)

Base.:(==)(x::BooleanExpr, y::BooleanExpr) = x.head == y.head && x.var == y.var && all(x.args .== y.args)
Base.hash(x::BooleanExpr, h::UInt) = hash(x.head, hash(x.var, hash(x.args, h)))
function evaluate(ex::BooleanExpr, dict::Dict{BooleanExpr, Bool})
    @assert all(is_var, keys(dict))
    evaluate(ex, Dict(k.var=>v for (k,v) in dict))
end
function evaluate(ex::BooleanExpr, dict::Dict{Symbol, Bool})
    if ex.head == :var
        if ex.var == Symbol("true")
            return true
        elseif ex.var == Symbol("false")
            return false
        else
            return dict[ex.var]
        end
    else
        fmap = arg->evaluate(arg, dict)
        if ex.head == :¬
            return !evaluate(ex.args[1], dict)
        elseif ex.head == :∨
            return any(fmap, ex.args)
        elseif ex.head == :∧
            return all(fmap, ex.args)
        elseif ex.head == :⊻
            return mapreduce(fmap, xor, ex.args)
        else
            _eval(Val(ex.head), dict, evaluate.(ex.args, Ref(dict))...)
        end
    end
end

# --------- Assignment --------------
struct Assignment
    outputs::Vector{Symbol}
    expr::BooleanExpr
end
Base.show(io::IO, x::Assignment) = print(io, join(string.(x.outputs), ", "), " = ", x.expr)
Base.show(io::IO, ::MIME"text/plain", x::Assignment) = show(io, x)
function extract_symbols!(ex::Assignment, vars::Vector{Symbol})
    append!(vars, ex.outputs)
    extract_symbols!(ex.expr, vars)
end

function evaluate!(exprs::Vector{Assignment}, dict::Dict{Symbol, Bool})
    for ex in exprs
        for o in ex.outputs
            dict[o] = evaluate(ex.expr, dict)
        end
    end
    return dict
end

# --------- Circuit --------------
"""
$TYPEDEF

A circuit expression is a sequence of assignments.

### Fields
- `exprs::Vector{Assignment}`: The assignments in the circuit.
"""
struct Circuit
    exprs::Vector{Assignment}
end

function Base.show(io::IO, x::Circuit)
    println(io, "Circuit:")
    print_statements(io, x.exprs)
end
function print_statements(io::IO, exprs)
    for (i, ex) in enumerate(exprs)
        print(io, "| ", ex)
        i < length(exprs) && println(io)
    end
end
Base.show(io::IO, ::MIME"text/plain", x::Circuit) = show(io, x)

function symbols(c::Circuit)
    vars = Symbol[]
    for ex in c.exprs
        extract_symbols!(ex, vars)
    end
    return unique!(vars)
end

function evaluate(c::Circuit, dict::Dict{Symbol, Bool})
    evaluate!(c.exprs, copy(dict))
end

"""
    @circuit circuit_expr

Construct a circuit expression from a block of assignments.

### Examples
```jldoctest
julia> @circuit begin
        x = a ∨ b
        y = x ∧ c
       end
Circuit:
| x = ∨(a, b)
| y = ∧(x, c)
```
"""
macro circuit(ex)
    render_circuit(ex)
end

function render_circuit(ex)
    @match ex begin
        :(begin $(exs...) end) => Circuit(render_circuit.(filter(x->!(x isa LineNumberNode), exs)))
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

function simple_form(c::Circuit)
    new_exprs = Assignment[]
    for ex in c.exprs
        handle_assign!(new_exprs, ex)
    end
    return Circuit(new_exprs)
end

function handle_assign!(new_exprs, ex::Assignment)
    ex.expr.head == :var && return push!(new_exprs, ex)
    newargs = map(ex.expr.args) do arg
        if arg.head == :var
            arg.var
        else
            out = gensym("var")
            handle_assign!(new_exprs, Assignment([out], arg))
            out
        end
    end
    push!(new_exprs, Assignment(ex.outputs, BooleanExpr(ex.expr.head, BooleanExpr.(newargs))))
end

# --------- CircuitSAT --------------
"""
$TYPEDEF

Circuit satisfiability problem, where the goal is to find an assignment that satisfies the circuit.

### Fields
- `circuit::Circuit`: The circuit expression in SSA form.
- `symbols::Vector{Symbol}`: The variables in the circuit.
"""
struct CircuitSAT <: AbstractProblem
    circuit::Circuit
    symbols::Vector{Symbol}
end
function CircuitSAT(circuit::Circuit)
    ssa = simple_form(circuit)
    vars = symbols(ssa)
    CircuitSAT(ssa, vars)
end
function Base.show(io::IO, x::CircuitSAT)
    println(io, "CircuitSAT:")
    print_statements(io, x.circuit.exprs)
    println(io)
    print(io, "Symbols: ", x.symbols)
end
Base.show(io::IO, ::MIME"text/plain", x::CircuitSAT) = show(io, x)

# variables interface
variables(c::CircuitSAT) = collect(1:length(c.symbols))
flavors(::Type{<:CircuitSAT}) = [0, 1]
problem_size(c::CircuitSAT) = (; num_exprs=length(c.circuit.exprs), num_variables=length(c.symbols))

# parameters interface
parameters(sat::CircuitSAT) = Int[]

function evaluate(sat::CircuitSAT, config)
    @assert length(config) == num_variables(sat)
    dict = Dict(sat.symbols[i]=>Bool(config[i]) for i in 1:length(sat.symbols))
    for ex in sat.circuit.exprs
        for o in ex.outputs
            @assert haskey(dict, o) "The output variable `$o` is not in the configuration"
            dict[o] != evaluate(ex.expr, dict) && return 1  # this is the loss!
        end
    end
    return 0
end
