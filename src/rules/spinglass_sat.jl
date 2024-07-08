function reduceto(::Type{<:SpinGlass}, sat::SATProblem)
    @assert is_cnf(sat) "SAT problem must be in CNF form"
    for clause in sat.args
    end
end

function problem_reduction()
end

# Ref:
# - https://support.dwavesys.com/hc/en-us/community/posts/1500000470701-What-are-the-cost-function-for-NAND-and-NOR-gates
# - https://journals.aps.org/prxquantum/abstract/10.1103/PRXQuantum.4.010316
struct SGGadget{WT}
    sg::SpinGlass{WT}
    inputs::Vector{Int}
    outputs::Vector{Int}
end
function Base.show(io::IO, ga::SGGadget)
    println(io, "SGGadget with $(nspin(ga.sg)) variables")
    println(io, "Inputs: $(ga.inputs)")
    println(io, "Outputs: $(ga.outputs)")
    print(io, "H = ")
    for (k, c) in enumerate(edges(ga.sg.graph))
        w = ga.sg.weights[k]
        iszero(w) && continue
        k == 1 || print(io, w >= 0 ? " + " : " - ")
        print(io, abs(w), "*", join(["s$ci" for ci in c], ""))
    end
end
Base.show(io::IO, ::MIME"text/plain", ga::SGGadget) = show(io, ga)

spinglass_gadget(s::Symbol) = spinglass_gadget(Val(s))
function spinglass_gadget(::Val{:∧})
    g = SimpleGraph(3)
    add_edge!(g, 1, 2)
    add_edge!(g, 1, 3)
    add_edge!(g, 2, 3)
    sg = SpinGlass(g, [1, -2, -2], [1, 1, -2])
    SGGadget(sg, [1, 2], [3])
end

function spinglass_gadget(::Val{:set0})
    g = SimpleGraph(1)
    sg = SpinGlass(g, Int[], [-1])
    SGGadget(sg, Int[], [1])
end

function spinglass_gadget(::Val{:¬})
    g = SimpleGraph(2)
    add_edge!(g, 1, 2)
    sg = SpinGlass(g, [1], [0, 0])
    SGGadget(sg, [1], [2])
end

function spinglass_gadget(::Val{:∨})
    g = SimpleGraph(3)
    add_edge!(g, 1, 2)
    add_edge!(g, 1, 3)
    add_edge!(g, 2, 3)
    sg = SpinGlass(g, [1, -2, -2], [-1, -1, 2])
    SGGadget(sg, [1, 2], [3])
end

function spinglass_circuit(sat::Circuit)
    ssa = ssa_form(sat)
    all_variables = Symbol[]
    modules = []
    for assignment in ssa.exprs
        gadget, variables = spinglass_gadget(assignment.expr)
        variables[gadget.outputs] .= assignment.outputs
        append!(all_variables, variables)
        push!(modules, (gadget.sg, variables))
    end
    unique!(all_variables)
    indexof(v) = findfirst(==(v), all_variables)
    sg = SpinGlass(HyperGraph(length(all_variables), Vector{Int}[]), Int[])
    for (m, variables) in modules
        add_sg!(sg, m, indexof.(variables))
    end
    return sg, all_variables
end

function spinglass_gadget(expr::BooleanExpr)
    modules = []
    inputs = Symbol[]
    middle = Symbol[]
    all_variables = Symbol[]
    for a in expr.args
        if is_var(a)
            push!(middle, a.var)
            push!(inputs, a.var)
            push!(all_variables, a.var)
        else
            circ, variables = spinglass_circuit(a)
            append!(all_variables, variables)
            push!(modules, (circ.sg, variables))
            append!(inputs, variables[circ.inputs])
            append!(middle, variables[circ.outputs])
        end
    end
    gadget_top = spinglass_gadget(expr.head)
    # map inputs
    vmap = Vector{Symbol}(undef, nspin(gadget_top.sg))
    vmap[gadget_top.inputs] .= middle
    # map outputs
    outputs = Symbol[]
    for v in gadget_top.outputs
        vmap[v] = gensym("spin")
        push!(outputs, vmap[v])
        push!(all_variables, vmap[v])
    end
    # map internal variables
    for v in setdiff(vertices(gadget_top.sg.graph), gadget_top.outputs ∪ gadget_top.inputs)
        vmap[v] = gensym("spin")
        push!(all_variables, vmap[v])
    end
    sg = SpinGlass(HyperGraph(length(all_variables), Vector{Int}[]), Int[])
    indexof(v) = findfirst(==(v), all_variables)
    for (m, variables) in modules
        add_sg!(sg, m, indexof.(variables))
    end
    add_sg!(sg, gadget_top.sg, indexof.(vmap))
    @assert nspin(sg) == length(all_variables)
    return SGGadget(sg, indexof.(inputs), indexof.(outputs)), all_variables
end

"""
    spinglass_gadget(::Val{:arraymul})

The array multiplier gadget.
```
    s_{i+1,j-1}  p_i
           \\     |
        q_j ------------ q_j
                 |
    c_{i,j} ------------ c_{i-1,j}
                 |     \\
                 p_i     s_{i,j} 
```
- variables: p_i, q_j, pq, c_{i-1,j}, s_{i+1,j-1}, c_{i,j}, s_{i,j}
- constraints: 2 * c_{i,j} + s_{i,j} = p_i q_j + c_{i-1,j} + s_{i+1,j-1}
"""
function spinglass_gadget(::Val{:arraymul})
    sg = SpinGlass(HyperGraph(7, Vector{Int}[]), Int[])
    add_sg!(sg, spinglass_gadget(Val(:∧)).sg, [1, 2, 3])
    for (clique, weight) in [[6, 7] => 2, [6, 3]=>-2, [6, 4]=>-2, [6, 5]=>-2,
                    [7, 3]=>-1, [7, 4]=>-1, [7, 5]=>-1,
                    [3, 4]=>1, [3, 5]=>1, [4, 5]=>1]
        add_clique!(sg, clique, weight)
    end
    return SGGadget(sg, [1, 2, 4, 5], [6, 7])
end

function add_sg!(sg::SpinGlass, g::SpinGlass, vmap::Vector{Int})
    @assert length(vmap) == nspin(g) "length of vmap must be equal to the number of vertices $(nspin(g)), got: $(length(vmap))"
    mapped_edges = [map(x->vmap[x], clique) for clique in edges(g.graph)]
    for (clique, weight) in zip(mapped_edges, g.weights)
        add_clique!(sg, clique, weight)
    end
    return sg
end
function add_clique!(sg::SpinGlass, clique::Vector{Int}, weight)
    for (k, c) in enumerate(edges(sg.graph))
        if sort(_vec(c)) == sort(clique)
            sg.weights[k] += weight
            return sg
        end
    end
    _add_edge!(sg.graph, clique)
    push!(sg.weights, weight)
    return sg
end
_vec(c::AbstractVector) = c
_vec(c::Graphs.SimpleEdge) = [c.src, c.dst]
_add_edge!(g::SimpleGraph, c::Vector{Int}) = add_edge!(g, c...)
function _add_edge!(g::HyperGraph, c::Vector{Int})
    @assert all(b->1<=b<=nv(g), c) "vertex index out of bound 1-$(nv(g)), got: $c"
    push!(g.edges, c)
end

function compose_multiplier(m::Int, n::Int)
    component = spinglass_gadget(Val(:arraymul)).sg
    sg = deepcopy(component)
    modules = []
    N = 0
    newindex!() = (N += 1)
    p = [newindex!() for _ = 1:m]
    q = [newindex!() for _ = 1:n]
    out = Int[]
    spre = [newindex!() for _ = 1:m]
    for s in spre push!(modules, [spinglass_gadget(:set0).sg, [s]]) end
    for j = 1:n
        s = [newindex!() for _ = 1:m]
        cpre = newindex!()
        push!(modules, [spinglass_gadget(:set0).sg, [cpre]])
        for i = 1:m
            c = newindex!()
            pins = [p[i], q[j], newindex!(), cpre, spre[i], c, s[i]]
            push!(modules, [component, pins])
            cpre = c
        end
        if j == n
            append!(out, s)
            push!(out, cpre)
        else
            # update spre
            push!(out, popfirst!(s))
            push!(s, cpre)
            spre = s
        end
    end
    sg = SpinGlass(SimpleGraph(N), Vector{Int}[], zeros(Int, N))
    for (m, pins) in modules
        add_sg!(sg, m, pins)
    end
    return SGGadget(sg, [p..., q...], out)
end

function set_input!(ga::SGGadget, inputs::Vector{Int})
    @assert length(inputs) == length(ga.inputs)
    for (k, v) in zip(ga.inputs, inputs)
        add_clique!(ga.sg, [k], v == 1 ? 1 : -1)  # 1 for down, 0 for up
    end
    return ga
end