"""
$TYPEDEF

The reduction result of a general SAT problem to an Dominating Set problem.

### Fields
$TYPEDFIELDS
"""
struct ReductionSATToDominatingSet{GT<:AbstractGraph} <: AbstractReductionResult
    target::DominatingSet{GT}  # the target problem
    num_literals::Int # number of literals in the SAT problem
    num_clauses::Int   # number of clauses in the SAT problem
end
target_problem(res::ReductionSATToDominatingSet) = res.target

@with_complexity 1 function reduceto(::Type{<:DominatingSet}, s::AbstractSatisfiabilityProblem)
    num_clauses = length(s.cnf.clauses)
    num_vertices = 3 * num_variables(s) + num_clauses
    g = SimpleGraph(num_vertices)
    for i in 1:num_variables(s)
        for m in 3*(i-1)+1:3*i
            for n in m:3*i
                add_edge!(g, m, n)
            end 
        end
    end
    for (i, clause_tmp) in enumerate(s.cnf.clauses)
        for literal in clause_tmp.vars
            literal_node = 3 * (findfirst(==(literal.name), variables(s))-1) + (literal.neg ? 2 : 1)
            add_edge!(g, literal_node, 3 * num_variables(s)+i)
        end
    end
    return ReductionSATToDominatingSet(DominatingSet(g), num_variables(s), num_clauses)
end

function extract_solution(res::ReductionSATToDominatingSet, sol)
    if count(value -> value == 1, sol) > res.num_literals
        return nothing
    end
    assignment = fill(0, res.num_literals)
    for (i, value) in enumerate(sol)
        if value == 1
            if value == 1
                if rem(i, 3) == 1
                    assignment[div(i, 3)+1] = 1
                elseif rem(i, 3) == 2
                    assignment[div(i, 3)+1] = 0
                elseif rem(i, 3) == 0
                    assignment[div(i, 3)] = rand([0,1])
                end
            end
        end
    end
    return assignment
end

function extract_multiple_solutions(res::ReductionSATToDominatingSet, sol)
    if count(value -> value == 1, sol[1]) > res.num_literals
        return []
    end
    all_assignments = Vector{Vector{Int}}()
    for sol_tmp in sol
        assignment = fill(0, res.num_literals)
        dummy_vars = Vector{Int}()
        for (i, value) in enumerate(sol_tmp)
            if value == 1
                if rem(i, 3) == 1
                    assignment[div(i, 3)+1] = 1
                elseif rem(i, 3) == 2
                    assignment[div(i, 3)+1] = 0
                elseif rem(i, 3) == 0
                    push!(dummy_vars, div(i, 3))
                end
            end
        end
        if length(dummy_vars) > 0
            for each_case in 0:( 2^( length(dummy_vars) ) - 1 )
                copied_assignment = copy(assignment)
                case_number = each_case
                for var in dummy_vars
                    copied_assignment[var] = rem(case_number, 2)
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

