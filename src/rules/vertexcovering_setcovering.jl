"""
$TYPEDEF

The reduction result of a vertex covering to a set covering problem.

### Fields
- `setcovering::SetCovering{ET,WT}`: the set covering problem, where ET is the sets type and WT is the weights type.
- `edgelabel`: map each edge to a number in order to identify the edge (otherwise the vector would be cluttering)
"""
struct ReductionVertexCoveringToSetCovering{ET, WT<:AbstractVector}
    setcovering::SetCovering{ET, WT}
    edgelabel::Dict{AbstractVector, Int}
end
Base.:(==)(a::ReductionVertexCoveringToSetCovering, b::ReductionVertexCoveringToSetCovering) = a.setcovering == b.setcovering && a.edgelabel == b.edgelabel

target_problem(res::ReductionVertexCoveringToSetCovering) = res.setcovering

function reduceto(::Type{<:SetCovering}, vc::VertexCovering)
    sc, edgelabel = vc2sc(vc) #vertexcovering2setcovering
    return ReductionVertexCoveringToSetCovering(sc,edgelabel)
end

# vertexcovering2setcovering
function vc2sc(vc::VertexCovering)
    edgelabel = edgetonumber(vc.graph)
    sets = Vector{Int}[]  # Initialize sets as Vector{Vector{Int}} type
    for j in 1:nv(vc.graph)
        set = Int[]  # for each vertex, initialize set as Int[] type
        for edge in keys(edgelabel)
            if edge[1] == j || edge[2] == j
                push!(set, edgelabel[edge])  # if the vertex is in the edge, add the edge number to the set
            end
        end
        sort!(set)  
        push!(sets, set)  # add the set to the sets
    end
    weights = vc.weights
    return SetCovering(sets, weights), edgelabel
end

# number the edges
function edgetonumber(g::SimpleGraph)
    edgelabel = Dict{AbstractVector, Int}()
    for (i, e) in enumerate(vedges(g))
        edgelabel[e] = i
    end
    return edgelabel
end

function extract_solution(res::ReductionVertexCoveringToSetCovering, sol)
    out = zeros(eltype(sol), num_variables(res.setcovering))
    for (k, v) in enumerate(variables(res.setcovering))
        out[v] = sol[k]
    end
    return out
end

