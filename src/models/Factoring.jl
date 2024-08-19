"""
    Factoring(m::Int, n::Int, input::Int)

The factoring problem is to find two numbers `a` and `b` such that `a * b = input`. And the numbers `a` and `b` are `m` and `n` bits long respectively.
"""
struct Factoring <: AbstractProblem
    m::Int       # number of bits for the first number
    n::Int       # number of bits for the second number
    input::Int   # the number to factorize
end

# variables interface
variables(f::Factoring) = collect(1:f.m+f.n)
flavors(::Type{Factoring}) = [0, 1]

# utilities
function evaluate(f::Factoring, config)
    @assert length(config) == num_variables(f)
    input1 = BitStr(config[1:f.m]).buf
    input2 = BitStr(config[f.m+1:f.m+f.n]).buf
    return input1 * input2 == f.input ? 0 : 1
end

pack_bits(bits) = sum(i->isone(bits[i]) ? 2^(i-1) : 0, 1:length(bits))