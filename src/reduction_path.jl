"""
    ReductionGraph

A directed graph representing the reduction paths between different problems.
A node represents a problem type, and an edge represents a reduction rule from one problem type to another.

### Fields
$TYPEDFIELDS
"""
struct ReductionGraph
    graph::SimpleDiGraph{Int}
    nodes::Vector{Any}
    method_table::Dict{Pair{Int, Int}, Method}
end

"""
    reduction_paths([rg::ReductionGraph, ]S::Type, T::Type)

Find all reduction paths from problem type `S` to problem type `T`.
Returns a list of paths, where each path is a sequence of problem types.

### Arguments
- `rg::ReductionGraph`: The reduction graph of type [`ReductionGraph`](@ref).
- `S::Type`: The source problem type.
- `T::Type`: The target problem type.
"""
function reduction_paths(::Type{S}, ::Type{T}) where {T <: AbstractProblem, S<:AbstractProblem}
    reduction_paths(reduction_graph(), S, T)
end
function reduction_paths(rg::ReductionGraph, ::Type{S}, ::Type{T}) where {T <: AbstractProblem, S<:AbstractProblem}
    source_nodes = [i for i in 1:nv(rg.graph) if S <: rg.nodes[i]]
    target_nodes = [i for i in 1:nv(rg.graph) if T <: rg.nodes[i]]
    paths = Vector{Int}[]
    for source_node in source_nodes, target_node in target_nodes
        append!(paths, all_simple_paths(rg.graph, source_node, target_node))
    end
    return map(p->getindex.(Ref(rg.nodes), p), paths)
end

"""
$TYPEDEF

A sequence of reductions.

### Fields
- `sequence::Vector{Any}`: The sequence of reductions.
"""
struct ConcatenatedReduction
    sequence::Vector{Any}
end
target_problem(cr::ConcatenatedReduction) = target_problem(cr.sequence[end])
function extract_solution(cr::ConcatenatedReduction, sol)
    for res in cr.sequence[end:-1:1]
        sol = extract_solution(res, sol)
    end
    return sol
end

"""
    implement_reduction_path(rg::ReductionGraph, path::AbstractVector, problem::AbstractProblem)

Implement a reduction path on a problem. Returns a [`ConcatenatedReduction`](@ref) instance.

### Arguments
- `path::AbstractVector`: A sequence of problem types, each element is an [`AbstractProblem`](@ref) instance.
- `problem::AbstractProblem`: The source problem, the type of which must be the same as the first node in the path.
"""
function implement_reduction_path(path::AbstractVector, problem::AbstractProblem)
    @assert problem isa path[1] "The problem type must be the same as the first node: $(path[1]), got: $problem"
    sequence = []
    for i=1:length(path)-1
        targetT = path[i+1]
        res = reduceto(targetT, problem)
        push!(sequence, res)
        problem = target_problem(res)
    end
    return ConcatenatedReduction(sequence)
end

"""
     reduction_graph()

Returns a [`ReductionGraph`](@ref) instance from the reduction rules defined with method `reduceto`.
"""
function reduction_graph()
    ms = methods(reduceto)
    rules = extract_types.(getfield.(ms, :sig))
    nodes = unique!(vcat(first.(rules), last.(rules)))
    graph = SimpleDiGraph(length(nodes))
    method_table = Dict{Pair{Int, Int}, Method}()
    for (rule, m) in zip(rules, ms)
        if rule.first == AbstractSatisfiabilityProblem
            for (i,j) in [
                (findfirst(==(Satisfiability), nodes),findfirst(==(last(rule)), nodes)),
                (findfirst(==(KSatisfiability), nodes),findfirst(==(last(rule)), nodes))
            ]
                add_edge!(graph, i, j)
                method_table[i=>j] = m
            end
        else
            i, j = findfirst(==(first(rule)), nodes), findfirst(==(last(rule)), nodes)
            add_edge!(graph, i, j)
            method_table[i=>j] = m
        end
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
        nodes = [offset(circlenode(LuxorGraphPlot.rotatepoint(LuxorGraphPlot.Point(800, 0), i*(2π/length(rg.nodes))),100),(100,100)) for i=1:length(rg.nodes)]
        append!(ns, nodes)
        Fadjlist = rg.graph.fadjlist
        Badjlist = rg.graph.badjlist
        with_nodes(ns) do
            LuxorGraphPlot.fontsize(16)
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

