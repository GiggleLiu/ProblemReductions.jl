"""
The reduction result of a general SAT problem to a 3-SAT problem.

### Fields
- `sat_source::Satisfiability{GT, T}`: the source general SAT problem.
"""
struct ReductionSATTo3SAT{T} <: AbstractReductionResult
    sat_source::Satisfiability{T}
    sat_target::KSatisfiability{3, T}
    new_var_map::Dict{Symbol, Symbol}
    inverse_new_var_map::Dict{Symbol, Symbol}
end
target_problem(res::ReductionSATTo3SAT) = res.sat_target

@with_complexity 1 function reduceto(::Type{<:KSatisfiability}, sat_source::Satisfiability)
    sat_source_renamed, new_var_map, inverse_new_var_map = rename_variables(sat_source)
    sat_target = transform_to_3_literal_cnf(sat_source_renamed)
    return ReductionSATTo3SAT(sat_source, sat_target, new_var_map, inverse_new_var_map )
end

function extract_solution(res::ReductionSATTo3SAT, sol)
    num_source_vars = num_variables(res.sat_source)
    target_vars = variables( res.sat_target )

    @assert length(sol) == length(target_vars)
    original_solution = fill(-1, num_source_vars) 
    for (i, new_var) in enumerate(target_vars)
        new_var_str = string(new_var)
        if startswith(new_var_str, "x_")
            original_index = parse(Int, new_var_str[3:end])
            original_solution[original_index] = sol[i]
        end
    end

    return original_solution
end

function extract_multiple_solutions(res::ReductionSATTo3SAT, sol_set)
    num_source_vars = num_variables(res.sat_source)
    target_vars = variables( res.sat_target )

    @assert length(sol_set[1]) == length(target_vars)
    all_original_solutions = Vector{Vector{Int64}}()
    for sol_tmp in sol_set
        original_solution = fill(-1, num_source_vars) 
        for (i, new_var) in enumerate(target_vars)
            new_var_str = string(new_var)
            if startswith(new_var_str, "x_")
                original_index = parse(Int, new_var_str[3:end])
                original_solution[original_index] = sol_tmp[i]
            end
        end
        push!(all_original_solutions, original_solution)
    end

    return unique( all_original_solutions )
end

# ----Useful functions----
# 001: Function to rename variables in the CNF
function rename_variables(sat::Satisfiability)
    
    original_vars = variables(sat)
    
    new_var_map = Dict{Symbol, Symbol}()
    inverse_new_var_map = Dict{Symbol, Symbol}()

    for (i, var_name) in enumerate(original_vars)
        new_var_map[var_name] = Symbol("x_$(i)")
        inverse_new_var_map[Symbol("x_$(i)")] = var_name
    end
    
    renamed_clauses = [
        CNFClause([BoolVar(new_var_map[var.name], var.neg) for var in clause.vars])
        for clause in sat.cnf.clauses
    ]
    
    new_cnf = CNF(renamed_clauses)
    
    return Satisfiability(new_cnf), new_var_map, inverse_new_var_map
end

# 002: Function to generate unique dummy variables
function generate_dummy_var(dummy_var_counter::Int)
    dummy_var_counter += 1
    return BoolVar(Symbol("z_$(dummy_var_counter)"), false), dummy_var_counter
end

# 003: Transform an arbitrary-length clause to 3-literal CNF
function transform_to_3_literal_clause(literals::Vector{BoolVar{Symbol}}, dummy_var_counter::Int)
    n = length(literals)
    transformed_clauses = Vector{CNFClause{Symbol}}() 

    if n == 1
        
        z1, dummy_var_counter = generate_dummy_var(dummy_var_counter)
        z2, dummy_var_counter = generate_dummy_var(dummy_var_counter)
        push!(transformed_clauses, CNFClause([literals[1], z1, z2]))
        push!(transformed_clauses, CNFClause([literals[1], BoolVar(z1.name, true), z2]))
        push!(transformed_clauses, CNFClause([literals[1], z1, BoolVar(z2.name, true)]))
        push!(transformed_clauses, CNFClause([literals[1], BoolVar(z1.name, true), BoolVar(z2.name, true)]))
        
    elseif n == 2
       
        z1, dummy_var_counter = generate_dummy_var(dummy_var_counter)
        push!(transformed_clauses, CNFClause([literals[1], literals[2], z1]))
        push!(transformed_clauses, CNFClause([literals[1], literals[2], BoolVar(z1.name, true)]))
    
    elseif n == 3
        
        push!(transformed_clauses, CNFClause([literals[1], literals[2], literals[3]]))

    else
        
        z1, dummy_var_counter = generate_dummy_var(dummy_var_counter)
        push!(transformed_clauses, CNFClause([literals[1], literals[2], z1]))

        for i in 3:n-2
            z_next, dummy_var_counter = generate_dummy_var(dummy_var_counter)
            push!(transformed_clauses, CNFClause([literals[i], BoolVar(z1.name, true), z_next]))
            z1 = z_next
        end

        push!(transformed_clauses, CNFClause([literals[n-1], literals[n], BoolVar(z1.name, true)]))
    end

    return transformed_clauses, dummy_var_counter
end

# 004: Function to transform CNF to 3-literal CNF
function transform_to_3_literal_cnf(sat::Satisfiability)
    transformed_clauses = Vector{CNFClause{Symbol}}() 
    dummy_var_counter = 0 

    for clause in sat.cnf.clauses

        transformed, dummy_var_counter = transform_to_3_literal_clause(clause.vars, dummy_var_counter)
        transformed_clauses = vcat(transformed_clauses, transformed)
    end
    
    return KSatisfiability{3}(CNF(transformed_clauses))
end

# ----KSatisfiability to General Satisfiability----
struct ReductionkSATToSAT{K, T} <: AbstractReductionResult
    sat_source::KSatisfiability{K, T}
    sat_target::Satisfiability{T}
end
target_problem(res::ReductionkSATToSAT) = res.sat_target

function reduceto(::Type{<:Satisfiability}, sat_source::KSatisfiability)
    return ReductionkSATToSAT(sat_source, Satisfiability(sat_source.cnf) )
end

function extract_solution(::ReductionkSATToSAT, sol)
    return sol
end
function extract_multiple_solutions(::ReductionkSATToSAT, sol_set)
    return sol_set
end