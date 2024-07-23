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

We only consider a simple reduction from SpinGlass to MaxCut(the graph must be `SimpleGraph`).
"""
struct ReductionSpinGlassToMaxCut{WT}
    maxcut::MaxCut{WT}
end

target_problem(res::ReductionSpinGlassToMaxCut) = res.maxcut

function reduceto(::Type{<:MaxCut}, sg::SpinGlass)
    mc = spinglass2maxcut(sg)
    return ReductionSpinGlassToMaxCut(mc)
end

function spinglass2maxcut(sg::SpinGlass)
    @assert sg.graph isa SimpleGraph "the graph must be `SimpleGraph`"
    return MaxCut(sg.graph, sg.weights)
end

function extract_solution(res::ReductionSpinGlassToMaxCut, sol)
    out = zeros(eltype(sol), num_variables(res.maxcut))
    for (k, v) in enumerate(variables(res.maxcut))
        out[v] = sol[k]
    end
    return out
end
