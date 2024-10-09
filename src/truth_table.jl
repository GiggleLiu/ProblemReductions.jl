"""
$TYPEDEF

The truth table.

### Fields
- `inputs::Vector{T}`: The input values.
- `outputs::Vector{T}`: The output values.
- `values::Vector{BitStr{N, Int}}`: The truth table values.

### Examples
```jldoctest
julia> tt = TruthTable(['a', 'b'], ['c'], [bit"0", bit"0", bit"0", bit"1"])
┌───┬───┬───┐
│ a │ b │ c │
├───┼───┼───┤
│ 0 │ 0 │ 0 │
│ 1 │ 0 │ 0 │
│ 0 │ 1 │ 0 │
│ 1 │ 1 │ 1 │
└───┴───┴───┘
```
"""
struct TruthTable{N, T}
	inputs::Vector{T}
    outputs::Vector{T}
    values::Vector{BitStr{N, Int}}
    function TruthTable(inputs::Vector{T}, outputs::Vector{T}, values::Vector{BitStr{N, Int}}) where {N, T}
        @assert length(values) == 2^(length(inputs))
        new{N, T}(inputs, outputs, values)
    end
end

function Base.getindex(tb::TruthTable, bs::BitStr{N}) where N
    @assert N == length(tb.inputs)
    return tb.values[bs.buf + 1]
end
Base.length(tb::TruthTable) = length(tb.values)

# visualization
Base.show(io::IO, ::MIME"text/plain", tb::TruthTable) = show(io, tb)
function Base.show(io::IO, tb::TruthTable)
    ni, no = length(tb.inputs), length(tb.outputs)
    entries = [Int(k > ni ? readbit(v, k-ni) : readbit(l-1, k)) for (l, v) in enumerate(tb.values), k in 1:ni+no]
	pretty_table(io, entries; header=vcat(tb.inputs, tb.outputs))
	return nothing
end

function infer_logic(configs, inputs::Vector{Int}, outputs::Vector{Int})
    output = Dict{Vector{Int}, Vector{Int}}()
    for c in configs
        key = c[inputs]
        if haskey(output, key)
            @assert output[key] == max(output[key], c[outputs]) "Inconsistent logic inference on input $key. Got configs: $configs"
        else
            output[key] = c[outputs]
        end
    end
    return output
end
function dict2table(inputs, outputs, d::Dict{Vector{Int}, Vector{Int}})
    ni, no = length(inputs), length(outputs)
    @assert length(d) == 2^ni "length of d must be equal to 2^ni ($(2^ni)), got: $(length(d))"
    return TruthTable(inputs, outputs, [BitStr(d[[readbit(k, i) for i=1:ni]]) for k in 0:length(d)-1])
end