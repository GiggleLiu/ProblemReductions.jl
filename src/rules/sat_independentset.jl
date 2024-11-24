"""
$TYPEDEF

The reduction result of a general SAT problem to an Independent Set problem.

### Fields
$TYPEDFIELDS
"""
struct ReductionSATToIndependentSet{S, GT<:AbstractGraph, T, WT<:AbstractVector{T}} <: AbstractReductionResult
    target::IndependentSet{GT, T, WT}  # the target problem
    literals::Vector{BoolVar{S}}  # the literals in the SAT problem
    source_variables::Vector{S}  # the variables in the SAT problem
    num_clauses::Int   # number of clauses in the SAT problem
end
target_problem(res::ReductionSATToIndependentSet) = res.target

function reduceto(::Type{IndependentSet{<:SimpleGraph}}, s::AbstractSatisfiabilityProblem)
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

function extract_solution(res::ReductionSATToIndependentSet{ST}, sol) where ST
    assignment = falses(length(res.source_variables))
    covered_literals_name = Vector{ST}()
    for (literal, value) in zip(res.literals, sol)
        iszero(value) && continue
        assignment[findfirst(==(literal.name), res.source_variables)] = !literal.neg
        push!(covered_literals_name, literal.name)
    end
    missed_literals_name = setdiff(res.source_variables, covered_literals_name)
    for literal_name in missed_literals_name
        assignment[findfirst(==(literal_name), res.source_variables)] = rand(Bool)
    end
    return assignment
end

function extract_multiple_solutions(res::ReductionSATToIndependentSet, sol_set)
    all_assignments = Vector{Vector{Bool}}()
    for sol_tmp in sol_set
        assignment = falses(length(res.source_variables))
        covered_literals_name = Vector{Symbol}()
        for (literal, value) in zip(res.literals, sol_tmp)
            iszero(value) && continue
            assignment[findfirst(==(literal.name), res.source_variables)] = !literal.neg
            push!(covered_literals_name, literal.name)
        end
        missed_literals_name = setdiff(res.source_variables, covered_literals_name)
        if length(missed_literals_name) > 0
            for each_case in 0:( 2^( length(missed_literals_name) ) - 1 )
                copied_assignment = copy(assignment)
                case_number = each_case
                for literal_name in missed_literals_name
                    copied_assignment[findfirst(==(literal_name), res.source_variables)] = rem(case_number, 2)
                    case_number = div(case_number, 2)
                end
                push!(all_assignments, copied_assignment)
            end
        else
            push!(all_assignments, assignment)
        end
    end
    return unique(all_assignments)
end


