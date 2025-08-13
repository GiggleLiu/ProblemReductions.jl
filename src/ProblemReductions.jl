module ProblemReductions

using Graphs, BitBasis
using DocStringExtensions
using PrettyTables
using BitBasis
using MLStyle
using JSON
using InteractiveUtils: subtypes

export @bit_str
export TruthTable
export HyperGraph, UnitDiskGraph, GridGraph, PlanarGraph, SimpleGraph
export @bv_str, StaticElementVector, StaticBitVector, statictrues, staticfalses, onehotv
export num_variables, num_flavors, variables, flavors, flavor_names, weights, set_weights, is_weighted, size, weight_type, problem_size
export UnitWeight

# models
export BooleanExpr, Circuit, Assignment, simple_form, CircuitSAT, @circuit, booleans, ¬, ∨, ∧, ⊻, is_literal, is_cnf, is_dnf
export SpinGlass, spinglass_gadget
export Coloring, is_vertex_coloring
export SetCovering, is_set_covering
export BoolVar, CNFClause, CNF, AbstractSatisfiabilityProblem, Satisfiability, is_kSAT, satisfiable, KSatisfiability
export MaxCut
export IndependentSet, is_independent_set
export VertexCovering, is_vertex_covering
export SetPacking, is_set_packing
export DominatingSet, is_dominating_set
export QUBO
export Factoring, is_factoring
export Matching, is_matching
export MaximalIS
export PaintShop
export BinaryMatrixFactorization, is_binary_matrix_factorization, read_solution
export BicliqueCover, is_biclique_cover, read_solution, biclique_cover_from_matrix

# rules
export target_problem, AbstractProblem, ConstraintSatisfactionProblem, solution_size, solution_size_multiple, SolutionSize, objectives, constraints, energy_mode
export energy, energy_mode, LargerSizeIsBetter, SmallerSizeIsBetter
export AbstractReductionResult, reduceto, extract_solution, extract_multiple_solutions, reduce_size
export LogicGadget, truth_table
export ReductionSATTo3SAT
export ReductionCircuitToSpinGlass, ReductionMaxCutToSpinGlass, ReductionSpinGlassToMaxCut, ReductionVertexCoveringToSetCovering, ReductionSatToColoring,
    ReductionSpinGlassToQUBO, ReductionQUBOToSpinGlass
export findbest, BruteForce, AbstractSolver, IPSolver
export CNF
export ReductionSATToIndependentSet, ReductionSATToDominatingSet
export ReductionIndependentSetToSetPacking, ReductionSetPackingToIndependentSet
export ReductionSATToCircuit
export ReductionIndependentSetToVertexCovering
export ReductionMatchingToSetPacking
export ReductionBMFToBicliqueCover, ReductionBicliqueCoverToBMF

# reduction path
export ReductionGraph, reduction_graph, reduction_paths, ConcatenatedReduction

include("truth_table.jl")
include("topology.jl")
include("bitvector.jl")
include("models/models.jl")
include("rules/rules.jl")
include("solvers.jl")
include("reduction_path.jl")
include("deprecated.jl")

@deprecate implement_reduction_path(path::ReductionPath, problem::AbstractProblem) reduceto(path, problem)

end
