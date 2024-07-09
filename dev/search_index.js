var documenterSearchIndex = {"docs":
[{"location":"models/SpinGlass/#Spin-Glass","page":"Spin Glass","title":"Spin Glass","text":"","category":"section"},{"location":"models/#Model-Problem","page":"Model Problem","title":"Model Problem","text":"","category":"section"},{"location":"models/","page":"Model Problem","title":"Model Problem","text":"A model problem is a subclass of AbstractProblem that defines the energy function of a graph problem.","category":"page"},{"location":"models/#Interfaces","page":"Model Problem","title":"Interfaces","text":"","category":"section"},{"location":"models/","page":"Model Problem","title":"Model Problem","text":"Required functions include:","category":"page"},{"location":"models/","page":"Model Problem","title":"Model Problem","text":"variables: The degrees of freedoms in the graph problem.   e.g. for the maximum independent set problems, they are the indices of vertices: 1, 2, 3...,   while for the max cut problem, they are the edges.\nflavors: A vector of integers as the flavors (or domain) of a degree of freedom.   e.g. for the maximum independent set problems, the flavors are [0, 1], where 0 means the vertex is not in the set and 1 means the vertex is in the set.\nterms: Variables that carrying local energies (or weights) in the graph problem.\nget_weights: Energies associated with terms. Returns the weights for the i-th term if a second argument is provided.\nevaluate: Evaluate the energy of a given configuration.","category":"page"},{"location":"models/","page":"Model Problem","title":"Model Problem","text":"Optional functions include:","category":"page"},{"location":"models/","page":"Model Problem","title":"Model Problem","text":"num_variables: The number of variables in the graph problem.\nnum_flavors: The number of flavors in the graph problem.\nchweights: Change the weights for the problem and return a new problem instance.\nnum_terms: The number of terms in the graph problem.\nweight_type: The data type of weights.\nfindbest: Find the best configurations in the graph problem.","category":"page"},{"location":"ref/#Reference","page":"Reference","title":"Reference","text":"","category":"section"},{"location":"ref/","page":"Reference","title":"Reference","text":"","category":"page"},{"location":"ref/","page":"Reference","title":"Reference","text":"Modules = [ProblemReductions]","category":"page"},{"location":"ref/#ProblemReductions.AbstractProblem","page":"Reference","title":"ProblemReductions.AbstractProblem","text":"AbstractProblem\n\nThe abstract base type of graph problems.\n\n\n\n\n\n","category":"type"},{"location":"ref/#ProblemReductions.AbstractReductionResult","page":"Reference","title":"ProblemReductions.AbstractReductionResult","text":"abstract type AbstractReductionResult\n\nThe base type for a reduction result.\n\n\n\n\n\n","category":"type"},{"location":"ref/#ProblemReductions.BruteForce","page":"Reference","title":"ProblemReductions.BruteForce","text":"BruteForce\n\nA brute force method to find the best configuration of a problem.\n\n\n\n\n\n","category":"type"},{"location":"ref/#ProblemReductions.CircuitSAT","page":"Reference","title":"ProblemReductions.CircuitSAT","text":"struct CircuitSAT <: AbstractProblem\n\nCircuit satisfiability problem, where the goal is to find an assignment that satisfies the circuit.\n\nFields\n\ncircuit::Circuit: The circuit expression in SSA form.\nsymbols::Vector{Symbol}: The variables in the circuit.\n\n\n\n\n\n","category":"type"},{"location":"ref/#ProblemReductions.GridGraph","page":"Reference","title":"ProblemReductions.GridGraph","text":"struct GridGraph <: Graphs.AbstractGraph{Int64}\n\nA grid graph is a graph in which the vertices are arranged in a grid and two vertices are connected by an edge if and only if they are adjacent in the grid.\n\nFields\n\ngrid::BitMatrix: a matrix of booleans, where true indicates the presence of an edge.\nradius::Float64: the radius of the unit disk\n\n\n\n\n\n","category":"type"},{"location":"ref/#ProblemReductions.HyperGraph","page":"Reference","title":"ProblemReductions.HyperGraph","text":"struct HyperGraph <: Graphs.AbstractGraph{Int64}\n\nA hypergraph is a generalization of a graph in which an edge can connect any number of vertices.\n\nFields\n\nn::Int: the number of vertices\nedges::Vector{Vector{Int}}: a vector of vectors of integers, where each vector represents a hyperedge connecting the vertices with the corresponding indices.\n\n\n\n\n\n","category":"type"},{"location":"ref/#ProblemReductions.ReductionCircuitToSpinGlass","page":"Reference","title":"ProblemReductions.ReductionCircuitToSpinGlass","text":"struct ReductionCircuitToSpinGlass{GT, T}\n\nThe reduction result of a circuit to a spin glass problem.\n\nFields\n\nspinglass::SpinGlass{GT, T}: the spin glass problem.\nvariables::Vector{Int}: the variables in the spin glass problem.\n\n\n\n\n\n","category":"type"},{"location":"ref/#ProblemReductions.SpinGlass","page":"Reference","title":"ProblemReductions.SpinGlass","text":"struct SpinGlass{GT<:Graphs.AbstractGraph, T} <: AbstractProblem\n\nSpinGlass(graph::AbstractGraph, J, h=zeros(nv(graph)))\n\nThe spin-glass problem.\n\nPositional arguments\n\ngraph is a graph object.\nweights are associated with the edges.\n\n\n\n\n\n","category":"type"},{"location":"ref/#ProblemReductions.StaticBitVector","page":"Reference","title":"ProblemReductions.StaticBitVector","text":"StaticBitVector{N,C} = StaticElementVector{N,1,C}\nStaticBitVector(x::AbstractVector)\n\nExamples\n\njulia> sb = StaticBitVector([1,0,0,1,1])\n10011\n\njulia> sb[3]\n0x0000000000000000\n\njulia> collect(Int, sb)\n5-element Vector{Int64}:\n 1\n 0\n 0\n 1\n 1\n\n\n\n\n\n","category":"type"},{"location":"ref/#ProblemReductions.StaticElementVector","page":"Reference","title":"ProblemReductions.StaticElementVector","text":"StaticElementVector{N,S,C}\nStaticElementVector(nflavor::Int, x::AbstractVector)\n\nN is the length of vector, C is the size of storage in unit of UInt64, S is the stride defined as the log2(# of flavors). When the number of flavors is 2, it is a StaticBitVector.\n\nFields\n\ndata is a tuple of UInt64 for storing the configuration of static elements.\n\nExamples\n\njulia> ev = StaticElementVector(3, [1,2,0,1,2])\n12012\n\njulia> ev[2]\n0x0000000000000002\n\njulia> collect(Int, ev)\n5-element Vector{Int64}:\n 1\n 2\n 0\n 1\n 2\n\n\n\n\n\n","category":"type"},{"location":"ref/#ProblemReductions.TruthTable","page":"Reference","title":"ProblemReductions.TruthTable","text":"struct TruthTable{N, T}\n\nThe truth table.\n\nFields\n\ninputs::Vector{T}: The input values.\noutputs::Vector{T}: The output values.\nvalues::Vector{BitStr{N, Int}}: The truth table values.\n\nExamples\n\njulia> tt = TruthTable(['a', 'b'], ['c'], [bit\"0\", bit\"0\", bit\"0\", bit\"1\"])\n┌───┬───┬───┐\n│ a │ b │ c │\n├───┼───┼───┤\n│ 0 │ 0 │ 0 │\n│ 1 │ 0 │ 0 │\n│ 0 │ 1 │ 0 │\n│ 1 │ 1 │ 1 │\n└───┴───┴───┘\n\n\n\n\n\n","category":"type"},{"location":"ref/#ProblemReductions.UnitDiskGraph","page":"Reference","title":"ProblemReductions.UnitDiskGraph","text":"struct UnitDiskGraph{D, T} <: Graphs.AbstractGraph{Int64}\n\nA unit disk graph is a graph in which the vertices are points in a plane and two vertices are connected by an edge if and only if the Euclidean distance between them is at most a given radius.\n\nFields\n\nn::Int: the number of vertices\nlocations::Vector{NTuple{D, T}}: the locations of the vertices\nradius::T: the radius of the unit disk\n\n\n\n\n\n","category":"type"},{"location":"ref/#ProblemReductions.chweights","page":"Reference","title":"ProblemReductions.chweights","text":"chweights(problem::AbstractProblem, weights) -> AbstractProblem\n\nChange the weights for the problem and return a new problem instance.\n\n\n\n\n\n","category":"function"},{"location":"ref/#ProblemReductions.evaluate","page":"Reference","title":"ProblemReductions.evaluate","text":"evaluate(problem::AbstractProblem, config) -> Real\n\nEvaluate the energy of the problem given the configuration config. The lower the energy, the better the configuration.\n\n\n\n\n\n","category":"function"},{"location":"ref/#ProblemReductions.extract_solution","page":"Reference","title":"ProblemReductions.extract_solution","text":"extract_solution(reduction::AbstractReductionResult, solution)\n\nExtract the solution solution of the target problem to the original problem.\n\nArguments\n\nreduction: The reduction result.\nsolution: The solution of the target problem.\n\n\n\n\n\n","category":"function"},{"location":"ref/#ProblemReductions.findbest","page":"Reference","title":"ProblemReductions.findbest","text":"findbest(problem::AbstractProblem, method) -> Vector\n\nFind the best configurations of the problem using the method.\n\n\n\n\n\n","category":"function"},{"location":"ref/#ProblemReductions.flavors-Tuple{GT} where GT<:AbstractProblem","page":"Reference","title":"ProblemReductions.flavors","text":"flavors(::Type{<:AbstractProblem}) -> Vector\n\nReturns a vector of integers as the flavors (domain) of a degree of freedom.\n\n\n\n\n\n","category":"method"},{"location":"ref/#ProblemReductions.get_weights","page":"Reference","title":"ProblemReductions.get_weights","text":"get_weights(problem::AbstractProblem[, i::Int]) -> Vector\n\nEnergies associated with terms. Returns the weights for the i-th term if a second argument is provided.\n\n\n\n\n\n","category":"function"},{"location":"ref/#ProblemReductions.num_flavors-Tuple{GT} where GT<:AbstractProblem","page":"Reference","title":"ProblemReductions.num_flavors","text":"num_flavors(::Type{<:AbstractProblem}) -> Int\n\nReturns the number of flavors (domain) of a degree of freedom.\n\n\n\n\n\n","category":"method"},{"location":"ref/#ProblemReductions.num_terms-Tuple{AbstractProblem}","page":"Reference","title":"ProblemReductions.num_terms","text":"num_terms(problem::AbstractProblem) -> Int\n\nThe number of terms in the graph problem.\n\n\n\n\n\n","category":"method"},{"location":"ref/#ProblemReductions.num_variables-Tuple{AbstractProblem}","page":"Reference","title":"ProblemReductions.num_variables","text":"num_variables(problem::AbstractProblem) -> Int\n\nThe number of variables in the graph problem.\n\n\n\n\n\n","category":"method"},{"location":"ref/#ProblemReductions.onehotv-Union{Tuple{C}, Tuple{S}, Tuple{N}, Tuple{Type{StaticElementVector{N, S, C}}, Any, Any}} where {N, S, C}","page":"Reference","title":"ProblemReductions.onehotv","text":"onehotv(::Type{<:StaticElementVector}, i, v)\nonehotv(::Type{<:StaticBitVector, i)\n\nReturns a static element vector, with the value at location i being v (1 if not specified).\n\n\n\n\n\n","category":"method"},{"location":"ref/#ProblemReductions.reduceto","page":"Reference","title":"ProblemReductions.reduceto","text":"reduceto(::Type{TA}, x::AbstractProblem)\n\nReduce the problem x to a target problem of type TA. Returns an instance of AbstractReductionResult.\n\nArguments\n\nTA: The target problem type.\nx: The original problem.\n\n\n\n\n\n","category":"function"},{"location":"ref/#ProblemReductions.spinglass_energy-Tuple{AbstractVector{Vector{Int64}}, Any}","page":"Reference","title":"ProblemReductions.spinglass_energy","text":"spinglass_energy(g::SimpleGraph, config; J, h)\nspinglass_energy(cliques::AbstractVector{Vector{Int}}, config; weights)\n\nCompute the spin glass state energy for the vertex configuration config. In the configuration, the spin ↑ is mapped to configuration 0, while spin ↓ is mapped to configuration 1. Let G=(VE) be the input graph, the hamiltonian is\n\nH = sum_ij in E J_ij s_i s_j + sum_i in V h_i s_i\n\nwhere s_i in -1 1 stands for spin ↓ and spin ↑.\n\nIn the hypergraph case, the hamiltonian is\n\nH = sum_c in C w_c prod_i in c s_i\n\nwhere C is the set of cliques, and w_c is the weight of the clique c.\n\n\n\n\n\n","category":"method"},{"location":"ref/#ProblemReductions.spinglass_gadget-Tuple{Val{:arraymul}}","page":"Reference","title":"ProblemReductions.spinglass_gadget","text":"spinglass_gadget(::Val{:arraymul})\n\nThe array multiplier gadget.\n\n    s_{i+1,j-1}  p_i\n           \\     |\n        q_j ------------ q_j\n                 |\n    c_{i,j} ------------ c_{i-1,j}\n                 |     \\\n                 p_i     s_{i,j} \n\nvariables: pi, qj, pq, c{i-1,j}, s{i+1,j-1}, c{i,j}, s{i,j}\nconstraints: 2 * c{i,j} + s{i,j} = pi qj + c{i-1,j} + s{i+1,j-1}\n\n\n\n\n\n","category":"method"},{"location":"ref/#ProblemReductions.target_problem","page":"Reference","title":"ProblemReductions.target_problem","text":"target_problem(res::AbstractReductionResult) -> AbstractProblem\n\nReturn the target problem of the reduction result.\n\n\n\n\n\n","category":"function"},{"location":"ref/#ProblemReductions.terms","page":"Reference","title":"ProblemReductions.terms","text":"terms(problem::AbstractProblem) -> Vector\n\nThe energy terms of a graph problem is defined as the variables that carrying local energies (or weights) in the graph problem.\n\n\n\n\n\n","category":"function"},{"location":"ref/#ProblemReductions.variables","page":"Reference","title":"ProblemReductions.variables","text":"variables(problem::AbstractProblem) -> Vector\n\nThe degrees of freedoms in the graph problem. e.g. for the maximum independent set problems, they are the indices of vertices: 1, 2, 3..., while for the max cut problem, they are the edges.\n\n\n\n\n\n","category":"function"},{"location":"ref/#ProblemReductions.weight_type-Tuple{AbstractProblem}","page":"Reference","title":"ProblemReductions.weight_type","text":"weight_type(problem::AbstractProblem) -> Type\n\nThe data type of the weights in the graph problem.\n\n\n\n\n\n","category":"method"},{"location":"ref/#ProblemReductions.@bv_str-Tuple{Any}","page":"Reference","title":"ProblemReductions.@bv_str","text":"Constructing a static bit vector.\n\n\n\n\n\n","category":"macro"},{"location":"ref/#ProblemReductions.@circuit-Tuple{Any}","page":"Reference","title":"ProblemReductions.@circuit","text":"@circuit circuit_expr\n\nConstruct a circuit expression from a block of assignments.\n\nExamples\n\njulia> @circuit begin\n        x = a ∨ b\n        y = x ∧ c\n       end\nCircuit:\n| x = ∨(a, b)\n| y = ∧(x, c)\n\n\n\n\n\n","category":"macro"},{"location":"","page":"Home","title":"Home","text":"CurrentModule = ProblemReductions","category":"page"},{"location":"#ProblemReductions","page":"Home","title":"ProblemReductions","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Documentation for ProblemReductions.","category":"page"},{"location":"rules/#Problem-Reduction-Rules","page":"Problem Reduction Rules","title":"Problem Reduction Rules","text":"","category":"section"},{"location":"rules/","page":"Problem Reduction Rules","title":"Problem Reduction Rules","text":"A problem reduction rule is a function that reduces a problem to another problem. By solving the target problem, we can extract the solution to the original problem. The reduction rule is defined as a function that takes an instance of the original problem and returns an AbstractReductionResult instance of the target problem.","category":"page"},{"location":"rules/#Interfaces","page":"Problem Reduction Rules","title":"Interfaces","text":"","category":"section"},{"location":"rules/","page":"Problem Reduction Rules","title":"Problem Reduction Rules","text":"reduceto: Reduce the source problem to a target problem of a specific type. Returns an AbstractReductionResult instance, which contains the target problem.\ntarget_problem: Return the target problem of the reduction result.\nextract_solution: Extract the solution of the target problem to the original problem.","category":"page"},{"location":"models/CircuitSAT/#Circuit-Satisfaction","page":"Circuit Satisfaction","title":"Circuit Satisfaction","text":"","category":"section"},{"location":"models/CircuitSAT/","page":"Circuit Satisfaction","title":"Circuit Satisfaction","text":"A circuit can be defined with the @circuit macro as follows:","category":"page"},{"location":"models/CircuitSAT/","page":"Circuit Satisfaction","title":"Circuit Satisfaction","text":"using ProblemReductions\n\ncircuit = @circuit begin\n    c = x ∧ y\n    d = x ∨ (c ∧ ¬z)\nend","category":"page"},{"location":"models/CircuitSAT/","page":"Circuit Satisfaction","title":"Circuit Satisfaction","text":"The circuit can be converted to a CircuitSAT problem instance:","category":"page"},{"location":"models/CircuitSAT/","page":"Circuit Satisfaction","title":"Circuit Satisfaction","text":"sat = CircuitSAT(circuit)","category":"page"},{"location":"models/CircuitSAT/","page":"Circuit Satisfaction","title":"Circuit Satisfaction","text":"Note that the circuit is converted to the static single assignment (SSA) form before the conversion. The symbols are variables in the circuit to be assigned to true or false.","category":"page"},{"location":"models/CircuitSAT/","page":"Circuit Satisfaction","title":"Circuit Satisfaction","text":"The circuit can be evaluated with the evaluate function:","category":"page"},{"location":"models/CircuitSAT/","page":"Circuit Satisfaction","title":"Circuit Satisfaction","text":"evaluate(sat, [true, false, true, true, false, false, true])","category":"page"},{"location":"models/CircuitSAT/","page":"Circuit Satisfaction","title":"Circuit Satisfaction","text":"The return value is 0 if the assignment satisfies the circuit, otherwise, it is the number of unsatisfied clauses.","category":"page"},{"location":"models/CircuitSAT/","page":"Circuit Satisfaction","title":"Circuit Satisfaction","text":"note: Note\nevaluate funciton returns lower values for better assignments.","category":"page"},{"location":"models/CircuitSAT/","page":"Circuit Satisfaction","title":"Circuit Satisfaction","text":"To find all satisfying assignments, use the findbest function:","category":"page"},{"location":"models/CircuitSAT/","page":"Circuit Satisfaction","title":"Circuit Satisfaction","text":"findbest(sat, BruteForce())","category":"page"},{"location":"models/CircuitSAT/","page":"Circuit Satisfaction","title":"Circuit Satisfaction","text":"Here, the BruteForce solver is used to find the best assignment.","category":"page"}]
}