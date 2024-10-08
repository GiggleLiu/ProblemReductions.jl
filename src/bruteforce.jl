"""
$TYPEDEF

A brute force method to find the best configuration of a problem.
"""
struct BruteForce end

function findbest(problem::AbstractProblem, ::BruteForce)
    best_size = Inf
    best_configs = Vector{Int}[]
    configs = Iterators.product([flavors(problem) for i in 1:num_variables(problem)]...)
    for (size, config) in energy_multi(problem, configs)
        if size == best_size
            push!(best_configs, collect(config))
        elseif size < best_size[1]
            best_size = Float64(size)
            empty!(best_configs)
            push!(best_configs, collect(config))
        end
    end
    return best_configs
end