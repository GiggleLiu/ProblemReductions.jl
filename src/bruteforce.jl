"""
$TYPEDEF

A brute force method to find the best configuration of a problem.
"""
Base.@kwdef struct BruteForce{T}
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
    flvs = flavors(problem)
    best_ids = NTuple{num_variables(problem), Int}[]
    configs = Iterators.product([1:length(flvs) for i in 1:num_variables(problem)]...)
    sizes = solution_size_byid(problem, configs)
    _find!(by, best_ids, configs, sizes, initial, bf.atol, bf.rtol)
    return [collect(id_to_config(problem, id)) for id in best_ids]
end

function _find!(compare, best_ids, configs, sizes, initial, atol, rtol)
    best_size = initial
    for (id, size) in zip(configs, sizes)
        !size.is_valid && continue
        if isapprox(size.size, best_size.size; atol, rtol)
            push!(best_ids, id)
        elseif compare(size, best_size)
            best_size = size
            empty!(best_ids)
            push!(best_ids, id)
        end
    end
end
