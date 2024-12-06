"""
$(TYPEDEF)

Prime Factorization (Factoring) is to decompose a number ``m`` into its prime factors ``p`` and ``q``, denoted as ``m = p × q``.

Fields
-------------------------------
- `m::Int`: number of bits for the first number
- `n::Int`: number of bits for the second number
- `input::Int`: the number to factorize

Example
-------------------------------
In the following example, the two 2 is the factors' bit size and 6 is the number to be factored. 6 is 110 in binary so its factors should be 2-bits number.
```jldoctest
julia> using ProblemReductions

julia> factoring = Factoring(2,2,6)
Factoring(2, 2, 6)

julia> variables(factoring) # return the sum of factors' bit size
1:4

julia> flavors(factoring)
(0, 1)

julia> energy(factoring,[0,1,1,1]) # 01 -> 2, 11 -> 3
0
```
"""
struct Factoring <: AbstractProblem
    m::Int       # number of bits for the first number
    n::Int       # number of bits for the second number
    input::Int   # the number to factorize
end

# variables interface
num_variables(f::Factoring) = f.m+f.n
flavors(::Type{Factoring}) = (0, 1)
problem_size(f::Factoring) = (; num_bits_first=f.m, num_bits_second=f.n)

# utilities
function energy_eval_byid_multiple(f::Factoring, config_ids)
    @assert all(id->length(id) == num_variables(f), config_ids)
    return Iterators.map(config_ids) do id
        input1 = BitStr(id[1:f.m] .- 1).buf
        input2 = BitStr(id[f.m+1:f.m+f.n] .- 1).buf
        return (input1 * input2 == f.input ? 0 : 1)
    end
end

pack_bits(bits) = sum(i->isone(bits[i]) ? 2^(i-1) : 0, 1:length(bits))