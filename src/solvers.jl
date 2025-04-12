abstract type AbstractSolver end

"""
$TYPEDEF

A brute force method to find the best configuration of a problem.
"""
Base.@kwdef struct BruteForce{T} <: AbstractSolver
    atol::T=eps(Float64)
    rtol::T=eps(Float64)
end

function Base.findmin(problem::AbstractProblem, method)
    findall(problem, method; initial=SolutionSize(Inf, false), by=(x, y) -> x.is_valid && (!y.is_valid || isless(x.size, y.size)))
end
function Base.findmax(problem::AbstractProblem, method)
    findall(problem, method; initial=SolutionSize(-Inf, false), by=(x, y) -> x.is_valid && (!y.is_valid || isless(y.size, x.size)))
end
function findbest(problem::AbstractProblem, method)
    energy_mode(problem) == LargerSizeIsBetter() ? findmax(problem, method) : findmin(problem, method)
end
function Base.findall(problem::AbstractProblem, bf::BruteForce; initial=SolutionSize(0.0, false), by=isless)
    best_configs = NTuple{num_variables(problem), Int}[]
    configs = Iterators.product([flavors(problem) for i in 1:num_variables(problem)]...)
    sizes = solution_size_multiple(problem, configs)
    _find!(by, best_configs, configs, sizes, initial, bf.atol, bf.rtol)
    return [collect(id) for id in best_configs]
end

function _find!(compare, best_configs, configs, sizes, initial, atol, rtol)
    best_size = initial
    for (config, size) in zip(configs, sizes)
        !size.is_valid && continue
        if isapprox(size.size, best_size.size; atol, rtol)
            push!(best_configs, config)
        elseif compare(size, best_size)
            best_size = size
            empty!(best_configs)
            push!(best_configs, config)
        end
    end
end

# Interface for IPSolver
Base.@kwdef struct IPSolver <: AbstractSolver 
    optimizer    # e.g. HiGHS.Optimizer
    max_itr::Int = 20
    verbose::Bool = false
end