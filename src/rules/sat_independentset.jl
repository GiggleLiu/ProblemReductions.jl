"""
The reduction result of a 3-SAT problem to an Independent Set problem.
"""
struct Reduction3SATToIndependentSet{T, GT}
    sat_source::Satisfiability{T}
    is_target::IndependentSet{GT}
    k::Int
    literal_to_nodes::Dict{BoolVar{T}, Vector{Int}}
end
target_problem(res::Reduction3SATToIndependentSet) = res.is_target

function reduceto(::Type{<:IndependentSet}, sat_source::Satisfiability)
    @assert is_kSAT( sat_source.cnf, 3)
    is_target, k, literal_to_nodes = reduce_3sat_to_independent_set(sat_source)
    return Reduction3SATToIndependentSet(sat_source, is_target, k, literal_to_nodes )
end

function extract_solution(res::Reduction3SATToIndependentSet, sol)
    if length( sol[1] ) >= res.k
        return transform_is_to_3sat_solution(res.sat_source, sol, res.literal_to_nodes )
    else
        return Vector{Int}()
    end
end

# ----Useful Functions----
function reduce_3sat_to_independent_set(s::Satisfiability{T}) where T
    @assert is_kSAT(s.cnf, 3)

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

        for i in 1:3
            for j in i+1:3
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


function transform_is_to_3sat_solution(sat_source::Satisfiability, sol::Vector{Vector{Int}}, literal_to_nodes::Dict{BoolVar{Symbol}, Vector{Int}})
    
    num_source_vars = num_variables(sat_source)
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
        end
        
    end

    return unique(all_original_solutions)
end
