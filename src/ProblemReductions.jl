module ProblemReductions

using Graphs

export @bv_str, StaticElementVector, StaticBitVector, statictrues, staticfalses, onehotv

include("Core.jl")
include("bitvector.jl")
include("sat.jl")
include("spinglass.jl")

end
