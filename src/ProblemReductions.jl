module ProblemReductions

using Graphs, BitBasis
using DocStringExtensions
using PrettyTables
using BitBasis
using MLStyle
using Random

export @bit_str
export TruthTable
export HyperGraph, UnitDiskGraph, GridGraph, PlanarGraph, SimpleGraph
export @bv_str, StaticElementVector, StaticBitVector, statictrues, staticfalses, onehotv
export num_variables, num_flavors, variables, flavors, parameters, set_parameters, evaluate, parameter_type, problem_size, configuration_space_size
export UnitWeight

# models
export BooleanExpr, Circuit, Assignment, simple_form, CircuitSAT, @circuit, booleans, ¬, ∨, ∧, ⊻, is_literal, is_cnf, is_dnf
export SpinGlass, spinglass_gadget
export Coloring, coloring_energy, is_vertex_coloring
export SetCovering, is_set_covering, set_covering_energy
export BoolVar, CNFClause, CNF, Satisfiability, is_kSAT, satisfiable, KSatisfiability
export MaxCut
export IndependentSet
export VertexCovering, is_vertex_covering, vertex_covering_energy
export SetPacking, is_set_packing
export DominatingSet
export QUBO
export Factoring
export Matching
export MaximalIS
export PaintShop

# rules
export target_problem, AbstractProblem, AbstractReductionResult, reduceto, extract_solution, extract_multiple_solutions, reduction_complexity
export LogicGadget, truth_table
export ReductionSATTo3SAT
export ReductionCircuitToSpinGlass, ReductionMaxCutToSpinGlass, ReductionSpinGlassToMaxCut, ReductionVertexCoveringToSetCovering, ReductionSatToColoring,
    ReductionSpinGlassToQUBO, ReductionQUBOToSpinGlass
export findbest, BruteForce
export CNF
export ReductionSATToIndependentSet, ReductionSATToDominatingSet
export ReductionIndependentSetToSetPacking
export ReductionSATToCircuit

# reduction path
export ReductionGraph, reduction_graph, reduction_paths, implement_reduction_path

include("truth_table.jl")
include("topology.jl")
include("bitvector.jl")
include("models/models.jl")
include("rules/rules.jl")
include("bruteforce.jl")
include("reduction_path.jl")

end
