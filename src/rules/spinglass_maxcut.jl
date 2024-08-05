"""
$TYPEDEF

The reduction result of a maxcut to a spin glass problem.

### Fields
- `spinglass::SpinGlass{GT, T}`: the spin glass problem.

We only consider a simple reduction from MaxCut to SpinGlass(the graph must be `SimpleGraph`).
"""
struct ReductionMaxCutToSpinGlass{GT, T}
    spinglass::SpinGlass{GT, T}
end

target_problem(res::ReductionMaxCutToSpinGlass) = res.spinglass

function reduceto(::Type{<:SpinGlass}, maxcut::MaxCut)
    sg = maxcut2spinglass(maxcut)
    return ReductionMaxCutToSpinGlass(sg)
end 

function maxcut2spinglass(maxcut::MaxCut)
    @assert maxcut.graph isa SimpleGraph "the graph must be `SimpleGraph`"
    return SpinGlass(maxcut.graph, maxcut.weights)
end

function extract_solution(res::ReductionMaxCutToSpinGlass, sol)
    out = zeros(eltype(sol), num_variables(res.spinglass))
    for (k, v) in enumerate(variables(res.spinglass))
        out[v] = sol[k]
    end
    return out
end

"""
$TYPEDEF

The reduction result of a spin glass to a maxcut problem.

### Fields
- `maxcut::MaxCut{WT}`: the MaxCut problem.
- `ancilla::Int`: the ancilla vertex.
"""
struct ReductionSpinGlassToMaxCut{WT}
    maxcut::MaxCut{WT}
    ancilla::Int
end
Base.:(==)(a::ReductionSpinGlassToMaxCut, b::ReductionSpinGlassToMaxCut) = a.maxcut == b.maxcut &&  a.ancilla == b.ancilla

target_problem(res::ReductionSpinGlassToMaxCut) = res.maxcut

function reduceto(::Type{<:MaxCut}, sg::SpinGlass)
    mc, ancilla = spinglass2maxcut(sg)
    return ReductionSpinGlassToMaxCut(mc,ancilla)
end

"""
    spinglass2maxcut(sg::SpinGlass)

If the graph is `SimpleGraph`, we could easily convert the SpinGlass to MaxCut.
If it's a HyperGraph, we need to convert it to a SimpleGraph first.
"""
function spinglass2maxcut(sg::SpinGlass{<:SimpleGraph})
    return MaxCut(sg.graph, sg.weights), 0
end

# modification
function spinglass2maxcut(sg::SpinGlass{<:HyperGraph})
    @assert all(c->length(c) <= 2, edges(sg.graph)) "Invalid HyperGraph" 
    n = length(unique!(vcat(vedges(sg.graph)...)))
    g = SimpleGraph(n+1) # the last two vertices are the source and sink,designed for onsite terms
    anc = n+1
    wt = eltype(sg.weights)[]
    for (w, c) in zip(sg.weights, vedges(sg.graph))
        if length(c) == 2  # simple edge
            add_edge!(g, c[1], c[2])
            push!(wt, w)
        else # onsite term
            add_edge!(g, c[1], anc)
            push!(wt, w)  # assume ancilla having spin up
        end
    end
    return MaxCut(g, wt), anc
end

function extract_solution(res::ReductionSpinGlassToMaxCut, sol)
    res.ancilla == 0 && return sol # no ancilla
    sol = sol[res.ancilla] == 0 ? sol : 1 .- sol  # the last index is the ancilla
    return deleteat!(copy(sol), res.ancilla)
end