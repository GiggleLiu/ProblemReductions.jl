"""
    Factoring <: AbstractProblem

Factoring problem. Given `input`, find its two prime factors, 

### Fields
$TYPEDFIELDS

where `m` is the number of bits for the first number, `n` is the number of bits for the second number, and `input` is the number to factorize.
"""
struct Factoring <: AbstractProblem
    m::Int       # number of bits for the first number
    n::Int       # number of bits for the second number
    input::Int   # the number to factorize
end

# variables interface
variables(f::Factoring) = collect(1:f.m+f.n)
flavors(::Type{Factoring}) = [0, 1]
problem_size(f::Factoring) = (; num_bits_first=f.m, num_bits_second=f.n)

# utilities
function energy_multi(f::Factoring, configs)
    @assert all(config->length(config) == num_variables(f), configs)
    return Iterators.map(configs) do config
        input1 = BitStr(config[1:f.m]).buf
        input2 = BitStr(config[f.m+1:f.m+f.n]).buf
        return (input1 * input2 == f.input ? 0 : 1, config)
    end
end

pack_bits(bits) = sum(i->isone(bits[i]) ? 2^(i-1) : 0, 1:length(bits))