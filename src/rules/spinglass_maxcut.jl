"""
$TYPEDEF

The reduction result of a maxcut to a spin glass problem.

### Fields
- `spinglass::SpinGlass{GT, T}`: the spin glass problem.

We only consider a simple reduction from MaxCut to SpinGlass(the graph must be `SimpleGraph`).
"""
struct ReductionMaxCutToSpinGlass{GT, T} <: AbstractReductionResult
    spinglass::SpinGlass{GT, T}
end

target_problem(res::ReductionMaxCutToSpinGlass) = res.spinglass

function reduceto(::Type{SpinGlass{<:SimpleGraph}}, maxcut::MaxCut)
    sg = SpinGlass(maxcut.graph, maxcut.weights, zeros(Int, nv(maxcut.graph)))
    return ReductionMaxCutToSpinGlass(sg)
end 

extract_solution(::ReductionMaxCutToSpinGlass, sol) = sol .== -1

"""
$TYPEDEF

The reduction result of a spin glass to a maxcut problem.

### Fields
- `maxcut::MaxCut{WT}`: the MaxCut problem.
- `ancilla::Int`: the ancilla vertex.
"""
struct ReductionSpinGlassToMaxCut{WT} <: AbstractReductionResult
    maxcut::MaxCut{WT}
    ancilla::Int
end
Base.:(==)(a::ReductionSpinGlassToMaxCut, b::ReductionSpinGlassToMaxCut) = a.maxcut == b.maxcut &&  a.ancilla == b.ancilla

target_problem(res::ReductionSpinGlassToMaxCut) = res.maxcut

# modification
function reduceto(::Type{MaxCut}, sg::SpinGlass{<:SimpleGraph})
    edgs = edges(sg.graph)
    n = nv(sg.graph)
    need_ancilla = any(c->num_vertices(c) <= 1, edgs) || any(!iszero, sg.h)
    g = SimpleGraph(need_ancilla ? n+1 : n) # the last two vertices are the source and sink,designed for onsite terms
    anc = need_ancilla ? n+1 : 0
    wt = eltype(sg.J)[]
    # add interaction terms
    for (w, c) in zip(sg.J, edgs)
        add_edge!(g, c)
        push!(wt, w)
    end
    # add onsite terms
    for (i, h) in enumerate(sg.h)
        if !iszero(h)
            add_edge!(g, i, anc)
            push!(wt, h)
        end
    end
    return ReductionSpinGlassToMaxCut(MaxCut(g, wt), anc)
end

function extract_solution(res::ReductionSpinGlassToMaxCut, sol)
    res.ancilla == 0 && return 1 .- 2 .* sol # no ancilla
    sol = sol[res.ancilla] == 0 ? 1 .- 2 .* sol : 2 .* sol .- 1  # the last index is the ancilla
    return deleteat!(copy(sol), res.ancilla)
end