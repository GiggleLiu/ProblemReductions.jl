module ProblemReductions

using Graphs, BitBasis
using DocStringExtensions
using PrettyTables
using BitBasis

export @bit_str
export TruthTable
export HyperGraph, UnitDiskGraph, GridGraph, PlanarGraph, SimpleGraph
export @bv_str, StaticElementVector, StaticBitVector, statictrues, staticfalses, onehotv
export Clause, booleans, ¬, ∨, ∧, ⊻, is_literal, is_cnf, is_dnf, compose_circuit
export SpinGlass, spinglass_gadget, nspin

include("Core.jl")
include("truth_table.jl")
include("topology.jl")
include("bitvector.jl")
include("sat.jl")
include("spinglass.jl")

end
