"""
$TYPEDEF
The reduction result of a  factoring problem to a CircuitSAT problem.

### Fields
- `circuit::CircuitSAT`: the CircuitSAT problem.
- `p::Vector{Int}`: the first number to multiply (store bit locations)
- `q::Vector{Int}`: the second number to multiply.
- `m::Vector{Int}`: the result of the multiplication.
"""
struct ReductionFactoringToSat <: AbstractReductionResult
    circuit::CircuitSAT
    p::Vector{Int}
    q::Vector{Int}
    m::Vector{Int}
end

target_problem(res::ReductionFactoringToSat) = res.circuit

function reduceto(::Type{<:CircuitSAT}, f::Factoring)
    # construct a circuit that multiplies two numbers
    n1, n2, z = f.m, f.n, f.input
    p = [BooleanExpr(Symbol("p$i")) for i in 1:n1]
    q = [BooleanExpr(Symbol("q$i")) for i in 1:n2]
    m = BooleanExpr[]
    others = BooleanExpr[]
    exprs = Assignment[]
    spres = BooleanExpr.(falses(n2+1))
    for i in 1:n1
        cpre = BooleanExpr(false)
        for j in 1:n2
            # spre: the signal from the previous cycle
            # cpre: the signal from the previous computational step
            # s + 2c = p*q + s_pre + c_pre
            c = BooleanExpr(Symbol("c$i$j"))
            s = BooleanExpr(Symbol("s$i$j"))
            mul_exprs, ancillas = multiplier(s, c, p[i], q[j], spres[j+1], cpre)
            append!(exprs, mul_exprs)
            cpre = c
            spres[j] = s
            push!(others, c)
            push!(others, s)
            append!(others, ancillas)
        end
        spres[end] = cpre
        push!(m, spres[1])
    end
    append!(m, spres[2:end])
    # set the target integer
    for i in 1:n1+n2
        push!(exprs, Assignment([m[i].var], BooleanExpr(Bool(readbit(z, i)))))
    end
    sat = CircuitSAT(Circuit(exprs))
    findvars(vars) = map(v->findfirst(==(v), sat.symbols), getfield.(vars, :var))
    return ReductionFactoringToSat(sat, findvars(p), findvars(q), findvars(m))
end

function extract_solution(res::ReductionFactoringToSat, sol)
    return vcat(sol[res.p], sol[res.q])
end

function multiplier(s::BooleanExpr, c::BooleanExpr, p::BooleanExpr, q::BooleanExpr, spre::BooleanExpr, cpre::BooleanExpr)
    a = BooleanExpr(gensym("a"))
    a_xor_s = BooleanExpr(gensym("a_xor_s"))
    a_xor_s_and_c = BooleanExpr(gensym("a_xor_s_and_c"))
    a_and_s = BooleanExpr(gensym("a_and_s"))
    return [
        Assignment([a.var], BooleanExpr(:∧, [p, q])),    # a = p & q
        Assignment([a_xor_s.var], BooleanExpr(:⊻, [a, spre])),  # a_xor_s = a ⊻ s_pre
        Assignment([s.var], BooleanExpr(:⊻, [a_xor_s, cpre])),  # s = a_xor_s ⊻ c_pre
        Assignment([a_xor_s_and_c.var], BooleanExpr(:∧, [a_xor_s, cpre])),  # a_xor_s_and_c = a_xor_s & c_pre
        Assignment([a_and_s.var], BooleanExpr(:∧, [a, spre])),  # a_and_s = a & s_pre
        Assignment([c.var], BooleanExpr(:∨, [a_xor_s_and_c, a_and_s]))  # c = a_xor_s_and_c | a_and_s
    ], [a, a_xor_s, a_xor_s_and_c, a_and_s]
end