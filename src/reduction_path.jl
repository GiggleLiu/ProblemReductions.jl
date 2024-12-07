"""
$TYPEDEF

A directed graph representing the reduction paths between different problems.
A node represents a problem type, and an edge represents a reduction rule from one problem type to another.

### Fields
$TYPEDFIELDS
"""
struct ReductionGraph
    graph::SimpleDiGraph{Int}
    nodes::Vector{Any}
    method_table::Dict{Pair{Int, Int}, Function}
end

"""
$TYPEDEF

A sequence of reductions.

### Fields
- `nodes::Vector{AbstractProblem}`: The sequence of problem types.
- `methods::Vector{Function}`: The sequence of methods used to reduce the problems.
"""
struct ReductionPath
    nodes::Vector{Any}
    methods::Vector{Function}
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
    target_nodes = [i for i in 1:nv(rg.graph) if rg.nodes[i] <: T]
    paths = Vector{Int}[]
    for source_node in source_nodes, target_node in target_nodes
        append!(paths, all_simple_paths(rg.graph, source_node, target_node))
    end
    return map(paths) do path
        nodes = getindex.(Ref(rg.nodes), path)
        ReductionPath(nodes, [rg.method_table[path[i]=>path[i+1]] for i in 1:length(path)-1])
    end
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

function reduceto(path::ReductionPath, problem::AbstractProblem)
    @assert problem isa path.nodes[1] "The problem type must be the same as the first node: $(path.nodes[1]), got: $problem"
    sequence = []
    for method in path.methods
        res = method(problem)
        push!(sequence, res)
        problem = target_problem(res)
    end
    return ConcatenatedReduction(sequence)
end

identity_reduction(::Type{<:AbstractProblem}, source) = IdentityReductionResult(source)  # trivial reduction

"""
     reduction_graph()

Returns a [`ReductionGraph`](@ref) instance from the reduction rules defined with method `reduceto`.
"""
function reduction_graph()
    ms = filter(methods(reduceto)) do m
        if !hasproperty(m.sig, :types)
            @warn "Illegal type signature as the first argument of `reduceto`, got $(m.sig). Note the `where` syntax is not supported yet. Skip this method."
            return false
        end
        m.sig.types[2] <: Type{<:AbstractProblem}
    end
    rules = extract_types.(getfield.(ms, :sig))
    nodes = unique!(vcat(concrete_subtypes(AbstractProblem), first.(rules), last.(rules)))
    graph = SimpleDiGraph(length(nodes))
    method_table = Dict{Pair{Int, Int}, Function}()

    # if T <: S, then add a trivial reduction rule
    for i in eachindex(nodes)
        for j in eachindex(nodes)
            if i !== j && nodes[i] <: nodes[j]
                add_edge!(graph, i, j)
                method_table[i=>j] = problem -> identity_reduction(nodes[j], problem)
            end
        end
    end
    for (rule, m) in zip(rules, ms)
        i, j = findfirst(x -> x == first(rule), nodes), findfirst(x -> x == last(rule), nodes)
        add_edge!(graph, i, j)
        method_table[i=>j] = problem -> reduceto(last(rule), problem)
    end
    return ReductionGraph(graph, nodes, method_table)
end

concrete_subtypes(type::Type) = concrete_subtypes!([], type)
function concrete_subtypes!(out, type::Type)
    if !isabstracttype(type)
        push!(out, type)
    else
        foreach(T->concrete_subtypes!(out, T), subtypes(type))
    end
    out
end

function extract_types(::Type{Tuple{typeof(reduceto), TA, TB}}) where {TA, TB}
    return TB => extract_type_type(TA)
end
function extract_type_type(t::UnionAll)
    @assert isdefined(t.body.parameters[1], :ub) "Illegal type signature as the first argument of `reduceto`, got $t. Note the `where` syntax is not supported yet."
    t.body.parameters[1].ub
end
extract_type_type(::Type{<:Type{T}}) where {T} = T
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
