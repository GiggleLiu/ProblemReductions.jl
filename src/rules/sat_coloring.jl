"""
$TYPEDEF
The reduction result of a Sat problem to a Coloring problem.

### Fields
- `Coloring{K, WT<:AbstractVector}`: the coloring problem, where K is the number of colors and WT is the weights type. 
- `varlabel`, used to filter extra variables

Note: The coloring problem is a 3 coloring problem, in which a auxiliary color is used Auxiliary color => 2.
"""
struct ReductionSatToColoring{K,T, WT<:AbstractVector}
    coloring::Coloring{K, WT}
    varlabel::Dict{T, Int}
end

target_problem(res::ReductionSatToColoring) = res.coloring

function reduceto(::Type{Coloring{3}},sat::Satisfiability{T}) where T #ensure the Sat problem is a Sat problem
    sc = SATColoringConstructor(BoolVar.(variables(sat)))
    for e in sat.cnf.clauses
        add_clause!(sc, e)
    end
    prob = Coloring{3}(sc.g, UnitWeight(ne(sc.g)))
    return ReductionSatToColoring(prob, sc.varlabel)
end

function extract_solution(res::ReductionSatToColoring, sol)
    out = zeros(eltype(sol),Int(length(res.varlabel)/2))
    t, f, a = sol[1:3]
    @assert t != f && t != a "Invalid solution!"
    for i in 4:3+Int(length(res.varlabel)/2)
        @assert sol[i] != a "Invalid solution, got auxiliary color: $a"
        out[i-3] = sol[i] == t
    end
    return out
end

# Construct the graph for the SAT problem and needed information
struct SATColoringConstructor{T}
    g::SimpleGraph{Int}    # the graph
    varlabel::Dict{T,Int}  # a map from variable name to vertex index
end
function SATColoringConstructor(variables::Vector{T}) where T<:BoolVar
    nv = length(variables)
    g = SimpleGraph(2*nv+3)
    for (i, j) in [(1, 2), (1, 3), (2, 3)]
        add_edge!(g, i, j)
    end
    for i in 1:nv
        a, nota = 3 + i, 3 + i + nv
        add_edge!(g, a, 3)   # attach_to_ancilla
        add_edge!(g, nota, 3)   # attach_to_ancilla
        add_edge!(g, a, nota)  # connect the variable and its negation
    end
    varlabel = merge!(Dict(zip(variables, 4:3+nv)), Dict(zip((¬).(variables), 4+nv:2*nv+3)))
    return SATColoringConstructor(g, varlabel)
end

true_vertex(sc::SATColoringConstructor) = 1
false_vertex(sc::SATColoringConstructor) = 2
ancilla_vertex(sc::SATColoringConstructor) = 3
function set_true!(sc::SATColoringConstructor, idx::Int)
    attach_to_ancilla!(sc, idx)
    attach_to_false!(sc, idx)
end
attach_to_ancilla!(sc::SATColoringConstructor, idx::Int) = _attach_to_idx!(sc, idx, ancilla_vertex(sc))
attach_to_false!(sc::SATColoringConstructor, idx::Int) = _attach_to_idx!(sc, idx, false_vertex(sc))
attach_to_true!(sc::SATColoringConstructor, idx::Int) = _attach_to_idx!(sc, idx, true_vertex(sc))
function _attach_to_idx!(sc::SATColoringConstructor{T}, idx::Int, kth::Int) where T
    add_edge!(sc.g, idx, kth)
end

function add_clause!(sc::SATColoringConstructor{T}, c::CNFClause) where T
    @assert length(c.vars) > 0 "The clause must have at least 1 variables"
    output_node = sc.varlabel[c.vars[1]] # get the first variable
    for i in c.vars[2:end]
       output_node = add_coloring_or_gadget!(sc, output_node, sc.varlabel[i])
    end
    set_true!(sc, output_node)
end

# `g`: the graph to add the gadget
# `input1`: the vertex index in `g` as the first input
# `input2`: the vertex index in `g` as the second input
# returns an output vertex number
function add_coloring_or_gadget!(sc::SATColoringConstructor{T}, input1::Int, input2::Int) where T
    add_vertices!(sc.g, 5) # add 5 nodes to the graph and track their index
    ancilla1, ancilla2, entrance1, entrance2, output = nv(sc.g)-4:nv(sc.g)

    # create the gadget
    attach_to_ancilla!(sc, output) # connect the output vertex to the auxiliary vertex
    attach_to_true!(sc, ancilla1)   # connect the ancilla1 to the true vertex
    for (i, j) in [(ancilla1, ancilla2), (ancilla2,input1), (ancilla2, input2), (entrance1,entrance2), 
        (output, ancilla1),(input1, entrance2), (input2, entrance1), (entrance1, output), (entrance2, output)]
        add_edge!(sc.g, i, j)
    end
    return output
end