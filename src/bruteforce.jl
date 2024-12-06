"""
$TYPEDEF

A brute force method to find the best configuration of a problem.
"""
struct BruteForce end

function findbest(problem::AbstractProblem, ::BruteForce; atol=eps(Float64), rtol=eps(Float64))
    flvs = flavors(problem)
    best_configs = Vector{eltype(flvs)}[]
    configs = Iterators.product([flvs for i in 1:num_variables(problem)]...)
    energies = energy_multi(problem, configs)
    _findbest!(best_configs, configs, energies, atol, rtol)
    return best_configs
end

function _findbest!(best_configs, configs, energies, atol, rtol)
    best_energy = Inf
    for (config, energy) in zip(configs, energies)
        if isapprox(energy, best_energy; atol, rtol)
            push!(best_configs, collect(config))
        elseif energy < best_energy
            best_energy = energy
            empty!(best_configs)
            push!(best_configs, collect(config))
        end
    end
end
