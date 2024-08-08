function reduction_paths(::Type{T}, source::AbstractProblem) where T <: AbstractProblem
    rg = reduction_graph()
    rules = methods(reduceto)
    paths = []
    source_nodes = [i for i in 1:nv(rg.graph) if source isa nodes[i]]
    target_nodes = [i for i in 1:nv(rg.graph) if T <: nodes[i]]
    for source_node in source_nodes
        for target_node in target_nodes
            path = dijkstra_shortest_paths(rg.graph, source_node)[target_node]
            if path !== nothing
                push!(paths, path)
            end
        end
    end
    return paths
end

struct ReductionGraph
    graph::SimpleDiGraph{Int}
    nodes::Vector{Any}
end

function reduction_graph()
    rules = extract_types.(getfield.(methods(reduceto), :sig))
    nodes = unique!(vcat(first.(rules), last.(rules)))
    graph = SimpleDiGraph(length(nodes))
    for rule in rules
        add_edge!(graph, findfirst(==(first(rule)), nodes), findfirst(==(last(rule)), nodes))
    end
    return ReductionGraph(graph, nodes)
end

function extract_types(::Type{Tuple{typeof(reduceto), TA, TB}}) where {TA, TB}
    return TB => TA.body.parameters[1].ub
end
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