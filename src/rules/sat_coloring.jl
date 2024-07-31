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
Base.:(==)(a::ReductionSatToColoring, b::ReductionSatToColoring) = a.coloring == b.coloring

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
    if sol[1] ==1 && sol[2] == 0 && sol[3] == 2
       for i in 4:3+Int(length(res.varlabel)/2)
              out[i-3] = sol[i]
       end
    else 
        return Int[] # invalid coloring output
    end
    return out
end


"""
Todo:Get the variables from the SAT problem and create 2 vertexs for themselves and their negations

then create a table gadget to simulate AND gate, add edges on all those variables and their negations also the auxiliary vertex in table gadget

after that checkout all the CNFClause in the e.clauses where e::CNF, put them into add_clause!(CNFClause). In this function, we would connect the variables with the 
output of the or gate in front of them and when reached the last OR gate, let the outcome be the True one in the table gadget

finally, return a graph and also collect the preset color for the table gadget, where we need to ensure the colors of -False, True and Auxiliary. Let it be [0,1,2]

So: tablegadget(g::SimpleGraph) to be the first function to call when creating a graph
var_vertex(v::Vector{T}},g::SimpleGraph) to be the second function to call when collecting the variables, where we need to add edges to var and table
For all the CNFClauses in the CNF, use a for loop to call, we only need to ensure every Cluases is true by connect the last OR gate to the table gadget
OR_gate(c::CNFCluases,g::SimpleGraph) to be the third function 
"""

"""
CNF2Graph(c::CNF)
This function return a graph that simulates the CNF problem
"""
function CNF2Graph(vars::AbstractVector{T}, c::CNF) where T <: BoolVar
    sc = SATColoringConstructor(vars)
    for e in c.clauses
        add_clause!(sc, e)
    end
    return g
end

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
function set_true!(sc::SATColoringConstructor, idx::Int) where T
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