module IPSolverExt

import JuMP
using ProblemReductions
using LinearAlgebra
using Combinatorics

include("combinations.jl")
include("hypercube.jl")
function Base.findmin(problem::AbstractProblem, solver::IPSolver)
    @assert num_flavors(problem) == 2 "findmin only supports boolean variables"
    cons = constraints(problem)
    nsc = ProblemReductions.num_variables(problem)
    maxN = maximum([length(c.variables) for c in cons])
    @assert maxN <= 5 "findmin only supports constraints with at most 5 variables"
    cuts = [all_sets_cuts(i) for i in 2:maxN]

    objs = objectives(problem)
    @assert all(length(obj.variables) <= 1 for obj in objs) "findmin only supports objectives with at most 1 variables"

    # IP by JuMP
    model = JuMP.Model(solver.optimizer)
    !solver.verbose && JuMP.set_silent(model)

    JuMP.@variable(model, 0 <= x[i = 1:nsc] <= 1, Int)
    # @objective(model, Max, sum(x[i] for i in 1:nsc))
    for con in cons
        subsets,ies = cuts[length(con.variables)-1]
        coverset = findall(!,con.specification)
        subset_pos = findall(set -> issubset(set, coverset),subsets)
        result = minimal_set_cover(coverset, subsets[subset_pos], solver.optimizer)
        for i in result
            ie = ies[subset_pos[i]]
            # 1: <=, 2: >=, 3: < , 4: >
            if ie.symb == 1
                JuMP.@constraint(model, sum(j-> x[con.variables[j]]*ie.hp.coefficients[j] , 1:length(con.variables)) <= ie.hp.offset)
            elseif ie.symb == 2
                JuMP.@constraint(model, sum(j-> x[con.variables[j]]*ie.hp.coefficients[j] , 1:length(con.variables)) >= ie.hp.offset)
            elseif ie.symb == 3
                JuMP.@constraint(model, sum(j-> x[con.variables[j]]*ie.hp.coefficients[j] , 1:length(con.variables)) <= ie.hp.offset-1e-2)
            elseif ie.symb == 4
                JuMP.@constraint(model, sum(j-> x[con.variables[j]]*ie.hp.coefficients[j] , 1:length(con.variables)) >= ie.hp.offset+1e-2)
            end
        end
    end
    
    obj_sum = 0
    for obj in objs
        obj_sum += x[obj.variables[1]]*obj.specification[1] + (1-x[obj.variables[1]])*obj.specification[2]
    end
    JuMP.@objective(model,Min, obj_sum)

    JuMP.optimize!(model)
    @assert JuMP.is_solved_and_feasible(model)
    return round.(Int, JuMP.value.(x))
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
    model = JuMP.Model(optimizer)
    !verbose && JuMP.set_silent(model)

    # Define binary variables for each subset (1 if selected, 0 if not)
    n = length(subsets)
    JuMP.@variable(model, x[1:n], Bin)
    
    # Each element in the coverset must be covered exactly once
    for element in coverset
        # Find all subsets containing this element
        covering_subsets = [i for i in 1:n if element in subsets[i]]
        
        # Each element must be covered exactly once
        JuMP.@constraint(model, sum(x[i] for i in covering_subsets) >= 1)
    end
    
    # Minimize the number of subsets used (optional objective)
    JuMP.@objective(model, Min, sum(x))
    # Solve the model
    JuMP.optimize!(model)
    
    # Return the solution if feasible
    if  JuMP.termination_status(model) ==  JuMP.MOI.OPTIMAL
        return [i for i in 1:n if  JuMP.value(x[i]) > 0.5]
    else
        error("No solution found")
    end
end

end