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
export num_variables, num_flavors, variables, flavors, parameters, set_parameters, evaluate, parameter_type
export UnitWeight

# models
export BooleanExpr, Circuit, Assignment, ssa_form, CircuitSAT, @circuit, booleans, ¬, ∨, ∧, ⊻, is_literal, is_cnf, is_dnf
export SpinGlass, spinglass_gadget
export Coloring, coloring_energy, is_vertex_coloring
export SetCovering, is_set_covering, set_covering_energy
export BoolVar, CNFClause, CNF, Satisfiability, is_kSAT, satisfiable
export MaxCut
export IndependentSet
export VertexCovering, is_vertex_covering, vertex_covering_energy
export SetPacking, is_set_packing
export DominatingSet
export QUBO

# rules
export target_problem, AbstractProblem, AbstractReductionResult, reduceto, extract_solution, reduction_complexity
export LogicGadget, truth_table
export ReductionCircuitToSpinGlass, ReductionMaxCutToSpinGlass, ReductionSpinGlassToMaxCut, ReductionVertexCoveringToSetCovering, ReductionSatToColoring,
    ReductionSpinGlassToQUBO, ReductionQUBOToSpinGlass
export findbest, BruteForce
export CNF
export Reduction3SATToIndependentSet

include("truth_table.jl")
include("topology.jl")
include("bitvector.jl")
include("models/models.jl")
include("rules/rules.jl")
include("bruteforce.jl")

end
