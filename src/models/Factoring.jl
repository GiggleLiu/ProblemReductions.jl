"""
$(TYPEDEF)

Prime Factorization (Factoring) is to decompose a number ``m`` into its prime factors ``p`` and ``q``, denoted as ``m = p × q``.

Fields
-------------------------------
- `m::Int`: number of bits for the first number
- `n::Int`: number of bits for the second number
- `input::T`: the number to factorize

Example
-------------------------------
In the following example, the two 2 is the factors' bit size and 6 is the number to be factored. 6 is 110 in binary so its factors should be 2-bits number.
```jldoctest
julia> using ProblemReductions

julia> factoring = Factoring(2,2,6)
Factoring{Int64}(2, 2, 6)

julia> variables(factoring) # return the sum of factors' bit size
1:4

julia> flavors(factoring)
(0, 1)

julia> solution_size(factoring,[0,1,1,1]) # 01 -> 2, 11 -> 3
SolutionSize{Int64}(0, true)
```
"""
struct Factoring{T} <: AbstractProblem
    m::Int       # number of bits for the first number
    n::Int       # number of bits for the second number
    input::T   # the number to factorize
end

# variables interface
num_variables(f::Factoring) = f.m+f.n
num_flavors(::Type{<:Factoring}) = 2
problem_size(f::Factoring) = (; num_bits_first=f.m, num_bits_second=f.n)

# utilities
function solution_size_multiple(f::Factoring, configs)
    @assert all(config->length(config) == num_variables(f), configs)
    return map(configs) do config
        input1 = BitStr(config[1:f.m]).buf
        input2 = BitStr(config[f.m+1:f.m+f.n]).buf
        return (input1 * input2 == f.input ? SolutionSize(0, true) : SolutionSize(0, false))
    end
end
solution_size(f::Factoring, config) = first(solution_size_multiple(f, [config]))
energy_mode(::Type{<:Factoring}) = SmallerSizeIsBetter()

pack_bits(bits) = sum(i->isone(bits[i]) ? BigInt(1) << (i-1) : BigInt(0), 1:length(bits); init=BigInt(0))

function read_solution(factoring::Factoring,solution::AbstractVector) #return a tuple of 2 numbers result
    num_m = pack_bits(solution[1:factoring.m])
    num_n = pack_bits(solution[factoring.m+1:end])
    return (num_m, num_n)
end

function is_factoring(f::Factoring, solution::AbstractVector)
    num_m, num_n = read_solution(f, solution)
    return num_m * num_n == f.input
end