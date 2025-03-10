@deprecate local_solution_spec local_solution_size
@deprecate size_terms function (problem::ConstraintSatisfactionProblem{T}) where T
    cons = map(constraints(problem)) do c
        (; variables = c.variables, solution_sizes = map(s->(; size = zero(T), is_valid = s), c.specification))
    end
    sizes = map(local_solution_size(problem)) do s
        (; variables = s.variables, solution_sizes = map(s->(; size = s, is_valid = true), s.specification))
    end
    return vcat(cons, sizes)
end

@deprecate id_to_config(problem::ConstraintSatisfactionProblem, config) config .- 1