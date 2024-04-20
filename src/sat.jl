struct SATProblem <: AbstractProblem
    clauses
end
struct Clause{N, C}
    mask::StaticBitVector{N, C}
    val::StaticBitVector{N, C}
end

Base.show(io::IO, c::Clause{N}) where{N} = print(io, "Clause($N, $(count_ones(c.mask))) \n mask = $(c.mask) \n val = $(c.val)")
booleans(n::Int) = [Clause(bmask(StaticBitVector{n, log2i(n)}, i), bmask(StaticBitVector{n, log2i(n)}, i)) for i=1:n]
∧(x::Clause, xs::Clause...) = Clause(reduce(|, getfield.(xs, :mask); init=x.mask), reduce(|, getfield.(xs, :val); init=x.val))
¬(x::Clause) = Clause(x.mask, flip(x.val, x.mask))
