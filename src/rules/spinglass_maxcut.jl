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
- `g::AbstractGraph`: the graph of the spinglass problem, we need it to extract the solution if it's hypergraph
"""
struct ReductionSpinGlassToMaxCut{WT}
    maxcut::MaxCut{WT}
    g::AbstractGraph
end
Base.:(==)(a::ReductionSpinGlassToMaxCut, b::ReductionSpinGlassToMaxCut) = a.maxcut == b.maxcut &&  a.g == b.g

target_problem(res::ReductionSpinGlassToMaxCut) = res.maxcut

function reduceto(::Type{<:MaxCut}, sg::SpinGlass)
    mc = spinglass2maxcut(sg)
    return ReductionSpinGlassToMaxCut(mc,sg.graph)
end

"""
    spinglass2maxcut(sg::SpinGlass)
    If the graph is `SimpleGraph`, we could easily convert the SpinGlass to MaxCut.
    If it's a HyperGraph, we need to convert it to a SimpleGraph first.
"""
function spinglass2maxcut(sg::SpinGlass{<:SimpleGraph})
    return MaxCut(sg.graph, sg.weights)
end

# modification
function spinglass2maxcut(sg::SpinGlass{<:HyperGraph})
    @assert all(c->length(c) <= 2, edges(sg.graph)) "Invalid HyperGraph" 
    n = length(unique!(vcat(vedges(sg.graph)...)))
    g = SimpleGraph(n+2) # the last two vertices are the source and sink,designed for onsite terms
    wt = zeros(eltype(sg.weights), num_variables(sg))
    for (i,c) in enumerate(edges(sg.graph))
        if length(c) == 2
            add_edge!(g, c[1], c[2])
            wt[i] = sg.weights[i]
        else
            k = (sg.weights[i] > 0) ? n+1 : n+2
            add_edge!(g, c[1], k)
            wt[i] = (k==n+1) ? -sg.weights[i] : sg.weights[i]
        end
    end
    return MaxCut(g, wt)
end

function extract_solution(res::ReductionSpinGlassToMaxCut, sol)
    if res.g isa SimpleGraph 
        out = zeros(eltype(sol), num_variables(res.maxcut))
        for (k, v) in enumerate(variables(res.maxcut))
            out[v] = sol[k]
        end
        return out
    elseif res.g isa HyperGraph
        out = zeros(eltype(sol), ne(res.g))
        if sol[end-1] == 1 && sol[end] == 0
            for (k, v) in enumerate(vedges(res.maxcut.graph))
                if k < length(out)
                    out[k] = (sol[v[1]] != sol[v[2]])
                end
            end
        end
        return out
    end
end

