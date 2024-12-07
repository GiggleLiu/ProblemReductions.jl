"""
$TYPEDEF

A brute force method to find the best configuration of a problem.
"""
struct BruteForce end

function findbest(problem::AbstractProblem, ::BruteForce; atol=eps(Float64), rtol=eps(Float64))
    flvs = flavors(problem)
    best_ids = NTuple{num_variables(problem), Int}[]
    configs = Iterators.product([1:length(flvs) for i in 1:num_variables(problem)]...)
    energies = energy_eval_byid_multiple(problem, configs)
    _findbest!(best_ids, configs, energies, atol, rtol)
    return [collect(id_to_config(problem, id)) for id in best_ids]
end

function _findbest!(best_ids, configs, energies, atol, rtol)
    best_energy = Inf
    for (id, energy) in zip(configs, energies)
        if isapprox(energy, best_energy; atol, rtol)
            push!(best_ids, id)
        elseif energy < best_energy
            best_energy = energy
            empty!(best_ids)
            push!(best_ids, id)
        end
    end
end
