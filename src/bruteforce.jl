"""
$TYPEDEF

A brute force method to find the best configuration of a problem.
"""
struct BruteForce end

function findmin(problem::AbstractProblem, ::BruteForce; atol=eps(Float64), rtol=eps(Float64))
    findall(problem, ::BruteForce; atol, rtol, initial=Inf, by=isless)
end
function findmax(problem::AbstractProblem, ::BruteForce; atol=eps(Float64), rtol=eps(Float64))
    findall(problem, ::BruteForce; atol, rtol, initial=-Inf, by=(x, y) -> isless(y, x))
end
function findall(problem::AbstractProblem, ::BruteForce; atol=eps(Float64), rtol=eps(Float64), initial=-Inf, by=isless)
    flvs = flavors(problem)
    best_ids = NTuple{num_variables(problem), Int}[]
    configs = Iterators.product([1:length(flvs) for i in 1:num_variables(problem)]...)
    sizes = size_eval_byid_multiple(problem, configs)
    _find!(by, best_ids, configs, sizes, initial, atol, rtol)
    return [collect(id_to_config(problem, id)) for id in best_ids]
end

function _find!(compare, best_ids, configs, sizes, initial, atol, rtol)
    best_size = initial
    for (id, size) in zip(configs, sizes)
        if isapprox(size, best_size; atol, rtol)
            push!(best_ids, id)
        elseif compare(size, best_size)
            best_size = size
            empty!(best_ids)
            push!(best_ids, id)
        end
    end
end
