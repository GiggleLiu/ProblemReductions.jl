function reduceto(::Type{<:CircuitSAT}, f::Factoring)
    # construct a circuit that multiplies two numbers
    n1, n2, z = f.m, f.n, f.z
    p = [BooleanExpr(Symbol("p$i")) for i in 1:n1]
    q = [BooleanExpr(Symbol("q$i")) for i in 1:n2]
    m = [BooleanExpr(Symbol("m$i")) for i in 1:n1+n2]
    others = BooleanExpr[]
    exprs = Assignment[]
    for i in 1:n1
        spres = BooleanExpr[]
        cpre = BooleanExpr(:false)
        for j in 1:n2
            # spre: the signal from the previous cycle
            # cpre: the signal from the previous computational step
            # s + 2c = p*q + s_pre + c_pre
            c = BooleanExpr(Symbol("c$i$j"))
            s = BooleanExpr(Symbol("s$i$j"))
            mul_exprs, ancillas = multiplier(s, c, p[i], q[j], j == n2 ? BooleanExpr(:false) : spres[j+1], cpre)
            append!(exprs, mul_exprs)
            append!(others, ancillas)
            cpre = c
            push!(spres, s)
            push!(others, c)
            push!(others, s)
        end
    end
    return CircuitSAT(Circuit(exprs), vcat(pvars, qvars, outputs, others))
end

function multiplier(s::BooleanExpr, c::BooleanExpr, p::BooleanExpr, q::BooleanExpr, spre::BooleanExpr, cpre::BooleanExpr)
    a = BooleanExpr(gensym("a"))
    a_xor_s = BooleanExpr(gensym("a_xor_s"))
    a_xor_s_and_c = BooleanExpr(gensym("a_xor_s_and_c"))
    a_and_s = BooleanExpr(gensym("a_and_s"))
    return [
        Assignment([a], BooleanExpr(:and, [p, q])),
        Assignment([a_xor_s], BooleanExpr(:xor, [a, spre])),
        Assignment([s], BooleanExpr(:xor, [a_xor_s, cpre])),
        Assignment([a_xor_s_and_c], BooleanExpr(:and, [a_xor_s, cpre])),
        Assignment([a_and_s], BooleanExpr(:and, [a, spre])),
        Assignment([c], BooleanExpr(:or, [a_xor_s_and_c, a_and_s]))
    ], [a, a_xor_s, a_xor_s_and_c, a_and_s]
end