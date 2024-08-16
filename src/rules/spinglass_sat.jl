"""
$TYPEDEF

The reduction result of a circuit to a spin glass problem.

### Fields
- `num_source_vars::Int`: the number of variables in the source circuit.
- `spinglass::SpinGlass{GT, T}`: the spin glass problem.
- `variables::Vector{Int}`: the variables in the spin glass problem.
"""
struct ReductionCircuitToSpinGlass{GT, T} <: AbstractReductionResult
    num_source_vars::Int
    spinglass::SpinGlass{GT, T}
    variables::Vector{Int}
end
target_problem(res::ReductionCircuitToSpinGlass) = res.spinglass

@with_complexity 1 function reduceto(::Type{<:SpinGlass}, sat::CircuitSAT)
    sg, all_variables = circuit2spinglass(sat.circuit)
    return ReductionCircuitToSpinGlass(num_variables(sat), sg, Int[findfirst(==(v), all_variables) for v in sat.symbols])
end

function circuit2spinglass(c::Circuit)
    ssa = simple_form(c)
    all_variables = Symbol[]
    modules = []
    for assignment in ssa.exprs
        gadget, variables = expr_to_spinglass_gadget(assignment.expr)
        variables[gadget.outputs] .= assignment.outputs
        append!(all_variables, variables)
        push!(modules, (gadget.problem, variables))
    end
    unique!(all_variables)
    indexof(v) = findfirst(==(v), all_variables)
    sg = SpinGlass(HyperGraph(length(all_variables), Vector{Int}[]), Int[])
    for (m, variables) in modules
        add_sg!(sg, m, indexof.(variables))
    end
    return sg, all_variables
end

function extract_solution(res::ReductionCircuitToSpinGlass, sol)
    out = zeros(eltype(sol), res.num_source_vars)
    for (k, v) in enumerate(res.variables)
        out[k] = sol[v] == -1
    end
    return out
end
#extract_multiple_solutions(res::ReductionCircuitToSpinGlass, sol_set) = unique( extract_solution.(Ref(res), sol_set) ) 

"""
$TYPEDEF

The logic gadget defined on an computational model.

### Fields
- `problem::PT`: the computational model, e.g., `SpinGlass`.
- `inputs::Vector{Int}`: the input variables.
- `outputs::Vector{Int}`: the output variables.

### References
- [What are the cost function for NAND and NOR gates?](https://support.dwavesys.com/hc/en-us/community/posts/1500000470701-What-are-the-cost-function-for-NAND-and-NOR-gates)
- Nguyen, M.-T., Liu, J.-G., Wurtz, J., Lukin, M.D., Wang, S.-T., Pichler, H., 2023. Quantum Optimization with Arbitrary Connectivity Using Rydberg Atom Arrays. [PRX Quantum 4, 010316.](https://doi.org/10.1103/PRXQuantum.4.010316)
"""
struct LogicGadget{PT<:AbstractProblem}
    problem::PT
    inputs::Vector{Int}
    outputs::Vector{Int}
end
function Base.show(io::IO, ga::LogicGadget)
    println(io, "LogicGadget:")
    println(io, "| Problem: $(ga.problem)")
    println(io, "| Inputs: $(ga.inputs)")
    println(io, "| Outputs: $(ga.outputs)")
end
Base.show(io::IO, ::MIME"text/plain", ga::LogicGadget) = show(io, ga)

spinglass_gadget(s::Symbol) = spinglass_gadget(Val(s))
function spinglass_gadget(::Val{:∧})
    g = SimpleGraph(3)
    add_edge!(g, 1, 2)
    add_edge!(g, 1, 3)
    add_edge!(g, 2, 3)
    sg = SpinGlass(g, [1, -2, -2], [1, 1, -2])
    LogicGadget(sg, [1, 2], [3])
end

function spinglass_gadget(::Val{:set0})
    g = SimpleGraph(1)
    sg = SpinGlass(g, Int[], [-1])
    LogicGadget(sg, Int[], [1])
end

function spinglass_gadget(::Val{:set1})
    g = SimpleGraph(1)
    sg = SpinGlass(g, Int[], [1])
    LogicGadget(sg, Int[], [1])
end

function spinglass_gadget(::Val{:¬})
    g = SimpleGraph(2)
    add_edge!(g, 1, 2)
    sg = SpinGlass(g, [1], [0, 0])
    LogicGadget(sg, [1], [2])
end

function spinglass_gadget(::Val{:∨})
    g = SimpleGraph(3)
    add_edge!(g, 1, 2)
    add_edge!(g, 1, 3)
    add_edge!(g, 2, 3)
    sg = SpinGlass(g, [1, -2, -2], [-1, -1, 2])
    LogicGadget(sg, [1, 2], [3])
end

function spinglass_gadget(::Val{:⊻})
    g = SimpleGraph(4)
    add_edge!(g, 1, 2)
    add_edge!(g, 1, 3)
    add_edge!(g, 1, 4)
    add_edge!(g, 2, 3)
    add_edge!(g, 2, 4)
    add_edge!(g, 3, 4)
    sg = SpinGlass(g, [1, -1, -2, -1, -2, 2], [1, 1, -1, -2])
    LogicGadget(sg, [1, 2], [3])
end

function expr_to_spinglass_gadget(expr::BooleanExpr)
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
            circ, variables = expr_to_spinglass_gadget(a)
            append!(all_variables, variables)
            push!(modules, (circ.problem, variables))
            append!(inputs, variables[circ.inputs])
            append!(middle, variables[circ.outputs])
        end
    end
    # handle true and false constants
    gadget_top = if expr.head == :var && expr.var == Symbol("true")
        spinglass_gadget(:set1)
    elseif expr.head == :var && expr.var == Symbol("false")
        spinglass_gadget(:set0)
    else
        spinglass_gadget(expr.head)
    end
    # map inputs
    vmap = Vector{Symbol}(undef, num_variables(gadget_top.problem))
    vmap[gadget_top.inputs] .= middle
    # map outputs
    outputs = Symbol[]
    for v in gadget_top.outputs
        vmap[v] = gensym("spin")
        push!(outputs, vmap[v])
        push!(all_variables, vmap[v])
    end
    # map internal variables
    for v in setdiff(vertices(gadget_top.problem.graph), gadget_top.outputs ∪ gadget_top.inputs)
        vmap[v] = gensym("spin")
        push!(all_variables, vmap[v])
    end
    sg = SpinGlass(HyperGraph(length(all_variables), Vector{Int}[]), Int[])
    indexof(v) = Int(findfirst(==(v), all_variables))
    for (m, variables) in modules
        add_sg!(sg, m, indexof.(variables))
    end
    add_sg!(sg, gadget_top.problem, indexof.(vmap))
    @assert num_variables(sg) == length(all_variables)
    return LogicGadget(sg, indexof.(inputs), indexof.(outputs)), all_variables
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
    add_sg!(sg, spinglass_gadget(Val(:∧)).problem, [1, 2, 3])
    for (clique, weight) in [[6, 7] => 2, [6, 3]=>-2, [6, 4]=>-2, [6, 5]=>-2,
                    [7, 3]=>-1, [7, 4]=>-1, [7, 5]=>-1,
                    [3, 4]=>1, [3, 5]=>1, [4, 5]=>1]
        add_clique!(sg, clique, weight)
    end
    return LogicGadget(sg, [1, 2, 4, 5], [6, 7])
end

function add_sg!(sg::SpinGlass, g::SpinGlass, vmap::Vector{Int})
    @assert length(vmap) == num_variables(g) "length of vmap must be equal to the number of vertices $(num_variables(g)), got: $(length(vmap))"
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
_add_edge!(g::SimpleGraph, c::Vector{Int}) = add_edge!(g, c...)
function _add_edge!(g::HyperGraph, c::Vector{Int})
    @assert all(b->1<=b<=nv(g), c) "vertex index out of bound 1-$(nv(g)), got: $c"
    push!(g.edges, c)
end

function compose_multiplier(m::Int, n::Int)
    component = spinglass_gadget(Val(:arraymul)).problem
    sg = deepcopy(component)
    modules = []
    N = 0
    newindex!() = (N += 1)
    p = [newindex!() for _ = 1:m]
    q = [newindex!() for _ = 1:n]
    out = Int[]
    spre = [newindex!() for _ = 1:m]
    for s in spre push!(modules, [spinglass_gadget(:set0).problem, [s]]) end
    for j = 1:n
        s = [newindex!() for _ = 1:m]
        cpre = newindex!()
        push!(modules, [spinglass_gadget(:set0).problem, [cpre]])
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
    return LogicGadget(sg, [p..., q...], out)
end

function set_input!(ga::LogicGadget, inputs::Vector{Int})
    @assert length(inputs) == length(ga.inputs)
    for (k, v) in zip(ga.inputs, inputs)
        add_clique!(ga.problem, [k], v == 1 ? 1 : -1)  # 1 for down, 0 for up
    end
    return ga
end

"""
    truth_table(ga::LogicGadget; variables=1:num_variables(ga.problem), solver=BruteForce())

Compute the truth table of a logic gadget.

### Arguments
- `ga::LogicGadget`: the logic gadget.

### Keyword Arguments
- `variables::Vector{Int}`: the variables to be displayed.
- `solver::AbstractSolver`: the solver to be used.
"""
function truth_table(ga::LogicGadget; variables=1:num_variables(ga.problem), solver=BruteForce())
    res = findbest(ga.problem, solver)
    logic_res = map(resi->flavor_to_logical.(typeof(ga.problem), resi), res)
    dict = infer_logic(logic_res, ga.inputs, ga.outputs)
    return dict2table(variables[ga.inputs], variables[ga.outputs], dict)
end