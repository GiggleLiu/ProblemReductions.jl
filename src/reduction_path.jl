"""
    reduction_paths(::Type{S}, ::Type{T}) -> Vector{Vector{Int}}

S is the source problem type and T is the target problem type. Return a nested vector containing all the reduction paths from S to T.
"""
function reduction_paths(::Type{S}, ::Type{T}) where {T <: AbstractProblem, S<:AbstractProblem}
    rg = reduction_graph()
    source_nodes = [i for i in 1:nv(rg.graph) if S <: rg.nodes[i]]
    target_nodes = [i for i in 1:nv(rg.graph) if T <: rg.nodes[i]]
    paths = Vector{Int}[]
    for source_node in source_nodes, target_node in target_nodes
        append!(paths, all_simple_paths(rg.graph, source_node, target_node))
    end
    return paths
end


struct ReductionGraph
    graph::SimpleDiGraph{Int}
    nodes::Vector{Any}
    method_table::Dict{Pair{Int, Int}, Method}
end

"""
$TYPEDEF

A sequence of reductions.

### Fields
- `sequence::Vector{Any}`: The sequence of reductions.
- `complexity::Int`: The complexity of the reduction.
"""
struct ConcatenatedReduction
    sequence::Vector{Any}
    complexity::Vector{Int}
end
target_problem(cr::ConcatenatedReduction) = target_problem(cr.sequence[end])
function extract_solution(cr::ConcatenatedReduction, sol)
    for res in cr.sequence[end:-1:1]
        sol = extract_solution(res, sol)
    end
    return sol
end
reduction_complexity(cr::ConcatenatedReduction) = prod(cr.complexity)

function implement_reduction_path(rg::ReductionGraph, path::Vector{Int}, problem::AbstractProblem)
    @assert problem isa rg.nodes[path[1]] "The problem type must be the same as the first node: $(rg.nodes[path[1]]), got: $problem"
    sequence = []
    complexity = []
    for i=1:length(path)-1
        targetT = rg.nodes[path[i+1]]
        res = reduceto(targetT, problem)
        push!(complexity, reduction_complexity(targetT, problem))
        push!(sequence, res)
        problem = target_problem(res)
    end
    return ConcatenatedReduction(sequence, complexity)
end

"""
    reduction_graph() -> ReductionGraph

Return the reduction graph 
"""
function reduction_graph()
    ms = methods(reduceto)
    rules = extract_types.(getfield.(ms, :sig))
    nodes = unique!(vcat(first.(rules), last.(rules)))
    graph = SimpleDiGraph(length(nodes))
    method_table = Dict{Pair{Int, Int}, Method}()
    for (rule, m) in zip(rules, ms)
        i, j = findfirst(==(first(rule)), nodes), findfirst(==(last(rule)), nodes)
        add_edge!(graph, i, j)
        method_table[i=>j] = m
    end
    return ReductionGraph(graph, nodes, method_table)
end

function extract_types(::Type{Tuple{typeof(reduceto), TA, TB}}) where {TA, TB}
    return TB => extract_type_type(TA)
end
extract_type_type(t::UnionAll) = t.body.parameters[1].ub
extract_type_type(t::DataType) = t
function extract_types(u::UnionAll)
    return extract_types(u.body, u.var)
end
function extract_types(t::Type{<:Tuple}, var::TypeVar)
    TA, TB = t.parameters[2], t.parameters[3]
    @assert TA isa Type "Not yet supported type signature, got $TA ← $TB"
    return render_type_params(var, TB) => render_type_params(var, TA.parameters[1])
end
render_type_params(::TypeVar, t::DataType) = t
render_type_params(var::TypeVar, t::UnionAll) = UnionAll(var, t)

function show_reduction_graph(rg::ReductionGraph)
    drawing = nodestore() do ns
        nodes = [offset(circlenode(LuxorGraphPlot.rotatepoint(LuxorGraphPlot.Point(2000, 0), i*(2π/length(rg.nodes))), 300), (100,100)) for i=1:length(rg.nodes)]
        append!(ns, nodes)
        Fadjlist = rg.graph.fadjlist
        Badjlist = rg.graph.badjlist
        with_nodes(ns) do
            LuxorGraphPlot.fontsize(40)
            for i in ns.nodes
                LuxorGraphPlot.stroke(i)
            end
            for (i, adj) in enumerate(Fadjlist)
                for j in adj
                    LuxorGraphPlot.stroke(Connection(ns.nodes[i], ns.nodes[j];mode = :natural, isarrow = :true))
                end
            end
            for (i, adj) in enumerate(Badjlist)
                for j in adj
                    LuxorGraphPlot.stroke(Connection(ns.nodes[j], ns.nodes[i];mode = :natural, isarrow = :true))
                end
            end
            for (i,j) in zip(1:length(ns.nodes),rg.nodes)
                LuxorGraphPlot.text("$j",ns.nodes[i])
            end
            
        end
        
    end
end

