function reduceto(::Type{<:CircuitSAT}, f::Factoring)
    # construct a circuit that multiplies two numbers
    n1, n2, z = f.m, f.n, f.z
    p = [BooleanExpr(Symbol("p$i")) for i in 1:n1]
    q = [BooleanExpr(Symbol("q$i")) for i in 1:n2]
    m = [BooleanExpr(Symbol("z$i")) for i in 1:n1+n2]
    others = BooleanExpr[]
    exprs = Assignment[]
    s = [BooleanExpr(Symbol("s$i$j")) for i in 1:n1+1, j in 0:n2]
    c = [BooleanExpr(Symbol("c$i$j")) for i in 0:n1, j in 1:n2]
    # initialize s
    for k = 1:size(s, 1)
        push!(exprs, Assignment([s[k, 1]], BooleanExpr(:false)))
    end
    # initialize c
    for k = 1:size(c, 2)
        push!(exprs, Assignment([c[1, k]], BooleanExpr(:false)))
    end
    for i in 1:n1
        for j in 1:n2
            # s + 2c = p*q + s_pre + c_pre
            mul_exprs, ancillas = multiplier(s[i, j+1], c[i+1, j], p[i], q[j], s[i+1, j], c[i, j])
            append!(exprs, mul_exprs)
            append!(others, ancillas)
        end
    end
    return CircuitSAT(Circuit(exprs), vcat(pvars, qvars, outputs, vec(s), vec(c), others))
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