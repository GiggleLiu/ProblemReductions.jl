"""
The reduction result of a general SAT problem to a 3-SAT problem.
"""
struct ReductionSATToKSAT{K, T} <: AbstractReductionResult
    sat_source::Satisfiability{T}
    sat_target::KSatisfiability{K, T}
end
target_problem(res::ReductionSATToKSAT) = res.sat_target

function reduceto(target_type::Type{<:KSatisfiability}, sat_source::Satisfiability; allow_less::Bool=false)
    K = get_k(target_type)
    cnf = CNF(CNFClause{Symbol}[])
    for clause in sat_source.cnf.clauses
        add_clause!(K, cnf, clause; allow_less)
    end
    return ReductionSATToKSAT(sat_source, KSatisfiability{K}(cnf; allow_less))
end

function extract_solution(res::ReductionSATToKSAT, sol)
    symbols_source = symbols(res.sat_source)
    symbols_target = symbols(res.sat_target)
    @assert length(sol) == length(symbols_target)
    d = Dict(zip(symbols_target, sol))
    return [d[s] for s in symbols_source]
end

function add_clause!(K::Int, cnf::CNF, clause::CNFClause; allow_less::Bool)
    if length(clause.vars) == K
        push!(cnf.clauses, clause)
    elseif length(clause.vars) < K
        if allow_less
            push!(cnf.clauses, clause)
        else
            anc = gensym("ancilla")
            trueliteral, falseliteral = BoolVar(anc, false), BoolVar(anc, true)
            add_clause!(K, cnf, CNFClause([clause.vars..., trueliteral]); allow_less)
            add_clause!(K, cnf, CNFClause([clause.vars..., falseliteral]); allow_less)
        end
    else
        clauses = cut_or_clause(K, clause)
        for c in clauses
            add_clause!(K, cnf, c; allow_less)
        end
    end
end
# cut the clause into k-or-less-literal clauses
function cut_or_clause(k::Int, clause::CNFClause)
    @assert k >= 3
    length(clause.vars) <= k && return [clause]
    anc = gensym("ancilla")
    c1 = CNFClause([clause.vars[1:k-1]..., BoolVar(anc, false)])
    return [c1, cut_or_clause(k, CNFClause([clause.vars[k:end]..., BoolVar(anc, true)]))...]
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