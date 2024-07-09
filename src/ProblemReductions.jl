module ProblemReductions

using Graphs, BitBasis
using DocStringExtensions
using PrettyTables
using BitBasis
using MLStyle

export @bit_str
export TruthTable
export HyperGraph, UnitDiskGraph, GridGraph, PlanarGraph, SimpleGraph
export @bv_str, StaticElementVector, StaticBitVector, statictrues, staticfalses, onehotv
export num_terms, num_variables, num_flavors, terms, variables, flavors, parameters, set_parameters, evaluate, parameter_type

# models
export Circuit, Assignment, ssa_form, CircuitSAT, @circuit, booleans, ¬, ∨, ∧, ⊻, is_literal, is_cnf, is_dnf
export SpinGlass, spinglass_gadget

# rules
export target_problem, AbstractProblem, AbstractReductionResult, reduceto, extract_solution
export spinglass_circuit
export findbest, BruteForce

include("truth_table.jl")
include("topology.jl")
include("bitvector.jl")
include("models/models.jl")
include("rules/rules.jl")
include("bruteforce.jl")

end
