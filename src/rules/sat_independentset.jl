"""
$TYPEDEF

The reduction result of a general SAT problem to an Independent Set problem.

### Fields
$TYPEDFIELDS
"""
struct ReductionSATToIndependentSet{T, GT<:AbstractGraph, WT<:AbstractVector}
    target::IndependentSet{GT, WT}  # the target problem
    literals::Vector{BoolVar{T}}  # the literals in the SAT problem
    source_variables::Vector{T}  # the variables in the SAT problem
    num_clauses::Int   # number of clauses in the SAT problem
end
target_problem(res::ReductionSATToIndependentSet) = res.target

@with_complexity 1 function reduceto(::Type{<:IndependentSet}, s::AbstractSatisfiabilityProblem)
    literals = BoolVar{eltype(variables(s))}[]
    g = SimpleGraph(0)
    for c in clauses(s)  # add edges between literals in the same clause
        add_vertices!(g, length(c.vars))
        append!(literals, c.vars)
        for i in nv(g)-length(c.vars)+1:nv(g), j in i+1:nv(g)  # add clique
            add_edge!(g, i, j)
        end
    end
    for i = 1:nv(g)       # add edges between variable and its negation
        for j=i+1:nv(g)
            literals[i] == ¬(literals[j]) && add_edge!(g, i, j)
        end
    end
    return ReductionSATToIndependentSet(IndependentSet(g), literals, variables(s), length(clauses(s)))
end

function extract_solution(res::ReductionSATToIndependentSet, sol)
    assignment = falses(length(res.source_variables))
    for (literal, value) in zip(res.literals, sol)
        iszero(value) && continue
        assignment[findfirst(==(literal.name), res.source_variables)] = !literal.neg
    end
    return assignment
end
