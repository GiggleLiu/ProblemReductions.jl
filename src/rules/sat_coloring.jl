"""
$TYPEDEF
The reduction result of a Sat problem to a Coloring problem.

### Fields
- `Coloring{K, WT<:AbstractVector}`: the coloring problem, where K is the number of colors and WT is the weights type. 
- `varlabel`, used to filter extra variables

Note: The coloring problem is a 3 coloring problem, in which a auxiliary color is used Auxiliary color => 2.
"""
struct ReductionSatToColoring{K, T, WT<:AbstractVector}
    coloring::Coloring{K, WT}
    varlabel::Dict{T, Int}
end
Base.:(==)(a::ReductionSatToColoring, b::ReductionSatToColoring) = a.coloring == b.coloring

target_problem(res::ReductionSatToColoring) = res.coloring

function reduceto(::Type{<:Coloring{K}}, sat::Satisfiability) where {K} #ensure the Sat problem is a Sat problem
    c, vl = sat2coloring(sat)
    return ReductionSatToColoring(c,vl)
end

function sat2coloring(sat::Satisfiability{T}) where T
    vl = Dict{T,Int}() #variable label
    for (k,v) in enumerate(variables(sat))
         vl[v] = k
    end
    g = CNF2Graph(variables(sat), sat.cnf)
    return Coloring{3}(g, UnitWeight(length(variables(sat)))), vl
end

function extract_solution(res::ReductionSatToColoring, sol)
    out = zeros(eltype(sol), num_variables(res.coloring))
    for (k, v) in enumerate(variables(res.coloring))
        out[v] = sol[k]
    end
    return out
end


"""
Todo:Get the variables from the SAT problem and create 2 vertexs for themselves and their negations

then create a table gadget to simulate AND gate, add edges on all those variables and their negations also the auxiliary vertex in table gadget

after that checkout all the CNFClause in the e.clauses where e::CNF, put them into OR_gate(CNFClause). In this function, we would connect the variables with the 
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
function CNF2Graph(vars::AbstractVector, c::CNF)
    len = length(vars)*2 + 3 # literals and their negations + 3 for the table gadget 
    g = SimpleGraph{Int64}(len)
    tablegadget(g)
    var_vertex(vars, g)
    for e in c.clauses
        OR_gate(e,g)
    end
    return g
end

function tablegadget(g::SimpleGraph)
    add_edge!(g,1,3)
    add_edge!(g,2,3)
    add_edge!(g,1,2)
end

function var_vertex(v::Vector{T},g::SimpleGraph) where T
    for i in 1:length(v)
        add_edge!(g,i,3) # 3 is the auxiliary vertex
        add_edge!(g,i+length(v),3) 
        add_edge!(g,i,i+length(v))# connect the variable and its negation
    end
end

function OR_gate(c::CNFClause,g::SimpleGraph)
    new_nodes = Int[]
    for i in c.vars
        if i!=c.vars[end] 
            OR_gate_gadget(new_nodes,g,false)
        else
            OR_gate_gadget(new_nodes,g,true) 
        end
        if i!=c.vars[end]
            add_edge!(g,new_nodes[end]-5,new_nodes[end]-1)
            add_edge!(g,i,new_nodes[end+1]-2)
            add_edge!(g,new_nodes[end]-1,new_nodes[end+1]-2)
            add_edge!(g,varlabel[i+1],new_nodes[end]-2) #  add_edge!(g,input,gadget_interface)
        else
            add_edge!(g,new_nodes[end]-5,new_nodes[end]-1)# add_edge!(g,input,gadget_interface)
            add_edge!(g,i,new_nodes[end]-2)# add_edge!(g,input,gadget_interface)
        end
    end
end

# `g`: the graph to add the gadget
# `input1`: the vertex index in `g` as the first input
# `input2`: the vertex index in `g` as the second input
# returns an output vertex number
function add_coloring_or_gadget!(g::SimpleGraph, input1::Int, input2::Int)
    # new_nodes::Vector{Int},
    # ,endofclause::Bool
    if endofclause # let the output be True(first vertex in the graph) to ensure the clause is true
        for j in 1:4
            push!(new_nodes,add_vertex!(g))
        end
        push!(new_nodes,1)
        add_edge!(g,new_nodes[end]-4,1)
        add_edge!(g,new_nodes[end],new_nodes[end]-1)
        add_edge!(g,new_nodes[end],new_nodes[end]-2)
        add_edge!(g,new_nodes[end]-1,new_nodes[end]-2)
        add_edge!(g,new_nodes[end],new_nodes[end]-4)
        add_edge!(g,new_nodes[end]-3,new_nodes[end]-4) 
    else
        for j in 1:5
        push!(new_nodes,add_vertex!(g))
        end
        add_edge!(g,new_nodes[end],3) # connect the output vertex to the auxiliary vertex
        add_edge!(g,new_nodes[end]-4,1)
        add_edge!(g,new_nodes[end],new_nodes[end]-1)
        add_edge!(g,new_nodes[end],new_nodes[end]-2)
        add_edge!(g,new_nodes[end]-1,new_nodes[end]-2)
        add_edge!(g,new_nodes[end],new_nodes[end]-4)
        add_edge!(g,new_nodes[end]-3,new_nodes[end]-4)
    end
    return new_nodes,g
end


