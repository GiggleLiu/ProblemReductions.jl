"""
    BruteForce

A brute force method to find the best configuration of a problem.
"""
struct BruteForce end

function findbest(problem::AbstractProblem, ::BruteForce)
    best_size = Inf
    best_configs = Vector{Int}[]
    for config in Iterators.product([flavors(problem) for i in 1:num_variables(problem)]...)
        size = Float64(evaluate(problem, collect(config)))
        if size == best_size
            push!(best_configs, collect(config))
        elseif size < best_size[1]
            best_size = size
            empty!(best_configs)
            push!(best_configs, collect(config))
        end
    end
    filter!(x->isempty(x), best_configs)
    unique!(best_configs) # remove empty and duplicates
    return best_configs
end