"""
The reduction result of a general SAT problem to an Independent Set problem.
"""
struct ReductionSATToIndependentSet{T, GT}
    sat_source::Satisfiability{T}
    is_target::IndependentSet{GT}
    k::Int
    literal_to_nodes::Dict{BoolVar{T}, Vector{Int}}
end
target_problem(res::ReductionSATToIndependentSet) = res.is_target

@with_complexity 1 function reduceto(::Type{<:IndependentSet}, sat_source::Satisfiability)
    is_target, k, literal_to_nodes = reduce_sat_to_independent_set(sat_source)
    return ReductionSATToIndependentSet(sat_source, is_target, k, literal_to_nodes )
end

function extract_solution(res::ReductionSATToIndependentSet, sol)
    
    return transform_is_to_sat_solution(res.sat_source, sol, res.literal_to_nodes )
    
end

# ----Useful Functions----
function reduce_sat_to_independent_set(s::Satisfiability{T}) where T

    k = length(s.cnf.clauses)
    num_nodes = 3 * k 
    graph = SimpleGraph(num_nodes)

    literal_to_nodes = Dict{BoolVar{T}, Vector{Int}}()
    node_counter = 0

    for clause_tmp in s.cnf.clauses
        
        clause_literals = clause_tmp.vars
        
        clause_nodes = []

        for var in clause_literals
            node_counter += 1

            literal_node = node_counter
            push!(clause_nodes, literal_node)

            if haskey(literal_to_nodes, var)
                push!(literal_to_nodes[var], literal_node)
            else
                literal_to_nodes[var] = [literal_node]
            end

        end

        for i in 1:length(clause_tmp)
            for j in i+1:length(clause_tmp)
                add_edge!(graph, clause_nodes[i], clause_nodes[j])
            end
        end
    end

    for (literal, nodes) in literal_to_nodes
        if haskey( literal_to_nodes, BoolVar(literal.name, literal.neg ? false : true) )
            for node in nodes
                for neg_node in literal_to_nodes[ BoolVar(literal.name, literal.neg ? false : true) ]
                    add_edge!(graph, node, neg_node)
                end
            end
        end
    end

    return IndependentSet(graph), k, literal_to_nodes
end

function transform_is_to_sat_solution(sat_source::Satisfiability, sol, literal_to_nodes::Dict{BoolVar{Symbol}, Vector{Int}})
    
    k = length(sat_source.cnf.clauses)
    num_source_vars = num_variables(sat_source)

    if sol isa Vector{ Vector{Int64} }
        all_original_solutions = Vector{Vector{Int64}}()
        for sol_tmp in sol
            assignments = Dict{Symbol, Int64}()

            for (vertex, vertex_true) in enumerate( sol_tmp )
        
                if vertex_true == 1
                    for (literal, nodes) in literal_to_nodes
                        if vertex in nodes
                            
                            if literal.neg
                                assignments[literal.name] = 0
                            else
                                assignments[literal.name] = 1
                            end
                            
                            break
                        end
                    end
                end
            end

            if length(assignments) == num_source_vars

                original_solution = fill(-1, num_source_vars) 
                for (var_i, var) in enumerate( variables( sat_source ) )
                    original_solution[var_i] = assignments[var]
                end
                push!(all_original_solutions, original_solution)

            elseif ( length( assignments ) != num_source_vars )

                literals_missed = []
                for literal in variables(sat_source)
                    if !haskey(assignments, literal)
                        push!(literals_missed, literal)
                    end
                end
                
                for each_case in 0:( 2^( length(literals_missed) ) - 1 )
                    complete_assignments = copy( assignments )
                    case_number = each_case
                    for literal in literals_missed
                        complete_assignments[literal] = rem(case_number, 2)
                        case_number = div(case_number, 2)
                    end

                    original_solution = fill(-1, num_source_vars) 
                    for (var_i, var) in enumerate( variables( sat_source ) )
                        original_solution[var_i] = complete_assignments[var]
                    end
                    
                    push!(all_original_solutions, original_solution)
                end

            end

        end
        
        return unique(all_original_solutions)
        
    elseif sol isa Vector{Int64}

        assignments = Dict{Symbol, Int64}()
        for (vertex, vertex_true) in enumerate( sol )
    
            if vertex_true == 1
                for (literal, nodes) in literal_to_nodes
                    if vertex in nodes
                        
                        if literal.neg
                            assignments[literal.name] = 0
                        else
                            assignments[literal.name] = 1
                        end
                        
                        break
                    end
                end
            end
        end
            
        if length(assignments) == num_source_vars

            original_solution = fill(-1, num_source_vars) 
            for (var_i, var) in enumerate( variables( sat_source ) )
                original_solution[var_i] = assignments[var]
            end
            return original_solution

        elseif ( length( assignments ) != num_source_vars )
            
            all_original_solutions = Vector{Vector{Int64}}()
            literals_missed = []
            for literal in variables(sat_source)
                if !haskey(assignments, literal)
                    push!(literals_missed, literal)
                end
            end
            @warn "return $(2^( length(literals_missed) )) degenerate solutions for single input"
            
            for each_case in 0:( 2^( length(literals_missed) ) - 1 )
                complete_assignments = copy( assignments )
                case_number = each_case
                for literal in literals_missed
                    complete_assignments[literal] = rem(case_number, 2)
                    case_number = div(case_number, 2)
                end

                original_solution = fill(-1, num_source_vars) 
                for (var_i, var) in enumerate( variables( sat_source ) )
                    original_solution[var_i] = complete_assignments[var]
                end
                
                push!(all_original_solutions, original_solution)
            end
            return unique(all_original_solutions)

        end

    end
end
