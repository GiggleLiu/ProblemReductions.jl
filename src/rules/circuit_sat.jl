"""
$TYPEDEF

The reduction result of an SAT problem o a Circuit SAT problem.

### Fields
- `target::CircuitSAT`: the target problem.
$TYPEDFIELDS
"""
struct ReductionSATToCircuit{} <: AbstractReductionResult
    target::CircuitSAT
    sat_symbols::Vector{Symbol}
end
target_problem(res::ReductionSATToCircuit) = res.target

@with_complexity 1 function reduceto(::Type{<:CircuitSAT}, s::Satisfiability)
    return ReductionSATToCircuit( cnf_to_circuit_sat(s.cnf), s.variables)
end

function clause_to_boolean_expr(clause::CNFClause{T}) where T
    literal_exprs = map(var -> 
        var.neg ? ¬( BooleanExpr(Symbol(var.name)) ) : BooleanExpr(Symbol(var.name)),
        clause.vars
    )
    if length(literal_exprs) == 1
        return literal_exprs[1]  
    else
        return BooleanExpr(:∨, literal_exprs)
    end
end

function cnf_to_circuit_sat(cnf::CNF{T}) where T
    exprs = Assignment[]  
    clause_outputs = Symbol[] 
    for clause in cnf.clauses
        clause_output = gensym("clause")  
        clause_expr = clause_to_boolean_expr(clause)  
        push!(exprs, Assignment([clause_output], clause_expr))  
        push!(clause_outputs, clause_output)  
    end
    final_output = gensym("out")  
    push!(exprs, Assignment([final_output], BooleanExpr(:∧, map(var -> BooleanExpr(var), clause_outputs))))
    circuit = Circuit(exprs)
    return CircuitSAT(circuit)
end

function extract_solution(res::ReductionSATToCircuit, sol)
    if sol[length(sol)] == false
        return nothing
    end
    extract_sol = falses(length(res.sat_symbols))
    for (i, var) in enumerate(res.sat_symbols)
        extract_sol[i] = sol[findfirst(==(var), res.target.symbols)]
    end
    return extract_sol
end

function extract_multiple_solutions(res::ReductionSATToCircuit, sol_set)
    all_assignments = Vector{Vector{Bool}}()
    for sol_tmp in sol_set
        if sol_tmp[length(sol_tmp)] == false
            continue
        end
        assignment = falses(length(res.sat_symbols))
        for (i, var) in enumerate(res.sat_symbols)
            assignment[i] = sol_tmp[findfirst(==(var), res.target.symbols)]
        end
        push!(all_assignments, assignment)
    end
    return unique(filter(sol -> sol !== nothing, all_assignments))
end
