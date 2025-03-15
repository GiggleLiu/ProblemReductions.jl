module IPSolverExt

using JuMP, ProblemReductions

function Base.findmin(problem::AbstractProblem, solver::IPSolver)
    cons = constraints(problem)
    objs = objectives(problem)
    # IP by JuMP
    model = Model(solver.optimizer)
    !solver.verbose && set_silent(model)

    @variable(model, 0 <= x[i = 1:nsc] <= 1, Int)
    @objective(model, Min, sum(x[i] * weights[i] for i in 1:nsc))
    for i in 1:num_items
        @constraint(model, sum(x[j] for j in sets_id[i]) >= 1)
    end

    optimize!(model)
    @assert is_solved_and_feasible(model)
    return round.(Int, value.(x))
end

function minimal_constraints(nflavor::Int, set::Vector)
    subsets = [covering_items(c, totalset) for c in clauses]
    return filter(set -> issubset(set, coverset), subsets)
end

"""
    minimal_set_cover(coverset::Vector{Int}, subsets::Vector{Vector{Int}}, optimizer)

Solve the set cover problem: all elements in the coverset must be covered by the subsets.
The objective is to minimize the number of subsets used.

# Arguments
- `coverset::Vector{Int}`: The set of all elements to be covered.
- `subsets::Vector{Vector{Int}}`: The set of subsets to choose from.
- `optimizer`: The optimizer to use, e.g. SCIP.Optimizer or HiGHS.Optimizer

# Returns
- `Vector{Int}`: The indices of the subsets to choose.
"""
function minimal_set_cover(coverset::Vector{Int}, subsets::Vector{Vector{Int}}, optimizer, verbose::Bool=false)
    # Remove subsets that cover not existing elements in the coverset
    @assert all(set -> issubset(set, coverset), subsets) "subsets ($subsets) must not cover any elements absent in the coverset ($coverset)"

    # Create a JuMP model for exact set cover
    model = Model(optimizer)
    !verbose && set_silent(model)

    # Define binary variables for each subset (1 if selected, 0 if not)
    n = length(subsets)
    @variable(model, x[1:n], Bin)
    
    # Each element in the coverset must be covered exactly once
    for element in coverset
        # Find all subsets containing this element
        covering_subsets = [i for i in 1:n if element in subsets[i]]
        
        # Each element must be covered exactly once
        @constraint(model, sum(x[i] for i in covering_subsets) >= 1)
    end
    
    # Minimize the number of subsets used (optional objective)
    @objective(model, Min, sum(x))
    # Solve the model
    optimize!(model)
    
    # Return the solution if feasible
    if termination_status(model) == MOI.OPTIMAL
        return [i for i in 1:n if value(x[i]) > 0.5]
    else
        error("No solution found")
    end
end

end