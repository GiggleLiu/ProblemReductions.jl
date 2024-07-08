struct CircuitSAT <: AbstractProblem
    expr::BooleanExpr
end

struct DNFClause{N, C}
    mask::StaticBitVector{N, C}
    val::StaticBitVector{N, C}
end

Base.show(io::IO, c::DNFClause{N}) where{N} = print(io, "DNFClause($N, $(count_ones(c.mask))) \n mask = $(c.mask) \n val = $(c.val)")
function staticbooleans(n::Int)
    s = _nints(n, 1)
    return map(1:n) do i
        v = onehotv(StaticBitVector{n, s}, i)
        DNFClause(v, v)
    end
end
∧(x::DNFClause, xs::DNFClause...) = DNFClause(reduce(|, getfield.(xs, :mask); init=x.mask), reduce(|, getfield.(xs, :val); init=x.val))
¬(x::DNFClause) = Or(x.mask, flip(x.val, x.mask))
BitBasis.flip(x::StaticBitVector{N,S}, mask::StaticBitVector{N,S}) where {N,S} = StaticBitVector{N,S}(flip.(x.data, mask.data))