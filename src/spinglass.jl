"""
$(TYPEDEF)
    SpinGlass(graph::AbstractGraph, J, h=zeros(nv(graph)))

The [spin-glass](https://queracomputing.github.io/GenericTensorNetworks.jl/dev/generated/SpinGlass/) problem.

Positional arguments
-------------------------------
* `graph` is a graph object.
* `weights` are associated with the cliques.
"""
struct SpinGlass{GT<:AbstractGraph, T} <: AbstractProblem
    graph::GT
    weights::Vector{T}
    function SpinGlass(n::Int, graph::AbstractGraph, weights::Vector{T}) where T
        @assert length(weights) == ne(graph)
        return new{typeof(graph), T}(n, graph, weights)
    end
end
function SpinGlass(graph::SimpleGraph, J::Vector, h::Vector)
    @assert length(J) == ne(graph) "length of J must be equal to the number of edges $(ne(graph)), got: $(length(J))"
    @assert length(h) == nv(graph) "length of h must be equal to the number of vertices $(nv(graph)), got: $(length(h))"
    SpinGlass(nv(graph), [[[src(e), dst(e)] for e in edges(graph)]..., [[i] for i in 1:nv(graph)]...], [J..., h...])
end
function spin_glass_from_matrix(M::AbstractMatrix, h::AbstractVector)
    g = SimpleGraph((!iszero).(M))
    J = [M[e.src, e.dst] for e in edges(g)]
    return SpinGlass(g, J, h)
end

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
    println(io, "SGGadget with $(ga.sg.n) variables")
    println(io, "Inputs: $(ga.inputs)")
    println(io, "Outputs: $(ga.outputs)")
    print(io, "H = ")
    for (k, c) in enumerate(edges(ga.sg.graphs))
        w = ga.sg.weights[k]
        iszero(w) && continue
        k == 1 || print(io, w >= 0 ? " + " : " - ")
        print(io, abs(w), "*", join(["s$ci" for ci in c], ""))
    end
end
Base.show(io::IO, ::MIME"text/plain", ga::SGGadget) = show(io, ga)

function sg_gadget_and()
    g = SimpleGraph(3)
    add_edge!(g, 1, 2)
    add_edge!(g, 1, 3)
    add_edge!(g, 2, 3)
    sg = SpinGlass(g, [1, -2, -2], [1, 1, -2])
    SGGadget(sg, [1, 2], [3])
end

function sg_gadget_set0()
    g = SimpleGraph(1)
    sg = SpinGlass(g, Int[], [-1])
    SGGadget(sg, Int[], [1])
end

function sg_gadget_not()
    g = SimpleGraph(2)
    add_edge!(g, 1, 2)
    sg = SpinGlass(g, [1], [0, 0])
    SGGadget(sg, [1], [2])
end

function sg_gadget_or()
    g = SimpleGraph(3)
    add_edge!(g, 1, 2)
    add_edge!(g, 1, 3)
    add_edge!(g, 2, 3)
    sg = SpinGlass(g, [1, -2, -2], [-1, -1, 2])
    SGGadget(sg, [1, 2], [3])
end

function to_sg_gadget(sat::CircuitSAT)
    if sat.head == :¬
        gnot = sg_gadget_not()
        a = to_sg_gadget(sat.args[1])
        return add_sg!(a, gnot.sg, a.outputs=>[gnot.inputs[1]])
    elseif sat.head == :∧
        gand = sg_gadget_and()
        a, b = [to_sg_gadget(a) for a in sat.args]
        sg = glue(a.sg, gand.sg, a.outputs=>[gand.inputs[1]])
    elseif sat.head == :∨
    elseif sat.head == :⊻
    else
        error("unsupported logic operation: $(sat.head)")
    end
end

# vmap defines a vector of equivalent variables
function glue(vmap, sgs::SpinGlass{GT, T}...) where {GT, T}
    nparts = length(sgs)
    @assert all(x->length(x) == nparts, vmap)
    @assert all([isunique(vcat(getindex.(vmap, k)...)) for k = 1:nparts])

    sizes = getfield.(sgs, :n)
    ns = cumsum([0; sizes])
    _new_indices = [collect(ns[i]+1:ns[i+1]) for i = 1:nparts]
    _vmap = map(m->[_new_indices[k][m[k]] for k=1:nparts], vmap)
    @show _vmap

    # find representatives for each equivalent set
    indexmap = Dict{Int, Int}()
    for equivalent_set in _vmap
        elements = vcat(equivalent_set...)
        representative = elements[1]
        for e in elements
            indexmap[e] = representative
        end
    end

    # get the new indices
    _new_indices_mapped = [map(e->get(indexmap, e, e), e) for e in _new_indices]
    @show _new_indices_mapped
    unique_indices = unique(vcat(_new_indices_mapped...))
    @show unique_indices
    remap = Dict(zip(unique_indices, 1:length(unique_indices)))
    @show remap
    new_indices_mapped = [map(e->remap[e], e) for e in _new_indices_mapped]
    @show new_indices_mapped

    n = length(unique_indices)
    cliques = Dict{Vector{Int}, T}()
    for k = 1:nparts
        sg = sgs[k]
        for (clique, weight) in zip(edges(sg.graph), sg.weights)
            new_clique = [new_indices_mapped[k][e] for e in clique]
            cliques[new_clique] = get(cliques, new_clique, zero(T)) + weight
        end
    end
    return SpinGlass(HyperGraph(n, collect(keys(cliques))), collect(values(weights)))
end
isunique(x) = length(unique(x)) == length(x)

function sg_gadget_arraymul()
    #   s_{i+1,j-1}  p_i
    #          \     |
    #       q_j ------------ q_j
    #                |
    #   c_{i,j} ------------ c_{i-1,j}
    #                |     \
    #                p_i     s_{i,j} 
    # variables: p_i, q_j, pq, c_{i-1,j}, s_{i+1,j-1}, c_{i,j}, s_{i,j}
    # constraints: 2 * c_{i,j} + s_{i,j} = p_i q_j + c_{i-1,j} + s_{i+1,j-1}
    sg = SpinGlass(7, Vector{Int}[], Int[])
    add_sg!(sg, sg_gadget_and().sg, [1, 2, 3])
    for (clique, weight) in [[6, 7] => 2, [6, 3]=>-2, [6, 4]=>-2, [6, 5]=>-2,
                    [7, 3]=>-1, [7, 4]=>-1, [7, 5]=>-1,
                    [3, 4]=>1, [3, 5]=>1, [4, 5]=>1]
        add_clique!(sg, clique, weight)
    end
    return SGGadget(sg, [1, 2, 4, 5], [6, 7])
end

function add_sg!(sg::SpinGlass, g::SpinGlass, vmap::Vector{Int})
    @assert length(vmap) == g.n
    mapped_cliques = [map(x->vmap[x], clique) for clique in g.cliques]
    for (clique, weight) in zip(mapped_cliques, g.weights)
        add_clique!(sg, clique, weight)
    end
    return sg
end
function add_clique!(sg::SpinGlass, clique::Vector{Int}, weight)
    for (k, c) in enumerate(sg.cliques)
        if sort(c) == sort(clique)
            sg.weights[k] += weight
            return sg
        end
    end
    push!(sg.cliques, clique)
    push!(sg.weights, weight)
    return sg
end

function compose_multiplier(m::Int, n::Int)
    component = sg_gadget_arraymul().sg
    sg = deepcopy(component)
    modules = []
    N = 0
    newindex!() = (N += 1)
    p = [newindex!() for _ = 1:m]
    q = [newindex!() for _ = 1:n]
    out = Int[]
    spre = [newindex!() for _ = 1:m]
    for s in spre push!(modules, [sg_gadget_set0().sg, [s]]) end
    for j = 1:n
        s = [newindex!() for _ = 1:m]
        cpre = newindex!()
        push!(modules, [sg_gadget_set0().sg, [cpre]])
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
    sg = SpinGlass(N, Vector{Int}[], Int[])
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
