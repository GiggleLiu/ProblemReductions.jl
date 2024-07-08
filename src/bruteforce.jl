function findbest(problem::AbstractProblem)
    best_size = typemax(energy_type(problem))
    best_configs = Vector{Int}[]
    for config in Iterators.product([flavors(problem) for i in 1:num_variables(problem)]...)
        size = evaluate(problem, collect(config))
        if size == best_size
            push!(best_configs, collect(config))
        elseif size < best_size[1]
            best_size = size
            empty!(best_configs)
            push!(best_configs, collect(config))
        end
    end
    return best_configs
end