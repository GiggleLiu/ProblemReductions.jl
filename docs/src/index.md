```@meta
CurrentModule = ProblemReductions
```

# ProblemReductions

This is the documentation for the open source package [ProblemReductions](https://github.com/GiggleLiu/ProblemReductions.jl),
a package for the reduction (or transformation) between computational hard problems.
Although the reduction is a common concept in the field of computational complexity, every textbook on this topic defines its own set of problems and reduction rules.
Unfortunately, these rules are not directly accessible to the public, especially for people in fields such as quantum many-body physics and statistical physics.
This package aims to collect a set of well-known problems and their reductions in one place, and provide a unified interface to access them.
We hope this will lower the barrier for researchers to enter this fascinating field.

## Framework

ProblemReductions defines a set of **computational hard problems** and the **reduction rules** between them. In the following diagram, we use an arrow pointing from problem A to problem B to indicate that there is a reduction rule from problem A to problem B.

![](./assets/reduction.svg)

The reduction rules induce a directed graph, called the **reduction graph**, where the nodes are the problems and the edges are the reductions.
Problem A can be reduced to problem B if and only if there is a path from A to B.
This reduction may consist of multiple steps, and the reduction path may not be unique.

The following example shows how to use the package to solve a simple factoring problem $? \times ? = 3$ by reducing it to an Ising model.
```@repl reduction_graph
using ProblemReductions
factoring = Factoring(2, 1, 3)  # define the factoring problem
paths = reduction_paths(Factoring, SpinGlass);
length(paths)   # you may find multiple reduction paths
res = reduceto(paths[1], factoring); # perform the reduction
problem_size(target_problem(res))
```
The [`Factoring`](@ref) problem is defined with two inputs of bit width 2 and 1, respectively.
We first query the reduction paths from the [Factoring](@ref) problem to the [SpinGlass](@ref) problem using [`reduction_paths`](@ref), and find multiple paths.
Each path is a [`ReductionPath`](@ref) instance.
We pick one reduction path and perform the reduction using [`reduceto`](@ref). The result is a [`ConcatenatedReduction`](@ref) instance, which contains not only the target problem, but also the intermediate reductions in the reduction path.
The target problem is an Ising model with 25 spins, which is exactly solvable using the [`BruteForce`](@ref) method implemented in [`findbest`](@ref):

```julia-repl
julia> sol = findbest(target_problem(res), BruteForce()); # solve the target problem

julia> extract_solution.(Ref(res), sol) # extract the solution to the original problem
1-element Vector{Vector{Int64}}:
 [1, 1, 1]
```

The solution to the original problem is extracted using [`extract_solution`](@ref). Note that the `findbest` funciton returns a set of equally good solutions, so broadcasting is used here.

## Model Problems
A model problem is a subclass of [`AbstractProblem`](@ref) that defines the size function of a computational problem.
Facts affecting the computational complexity classification of the problem also include the topology of the problem and the domain of the variables.

The required interfaces are specified in [`AbstractProblem`](@ref). The following code lists all problems subtyping it:
```@repl reduction_graph
ProblemReductions.concrete_subtypes(AbstractProblem)
```
Please check [Problems zoo](@ref) and our paper [arXiv:2501.00227](https://arxiv.org/abs/2501.00227) for more their definitions and properties.

```@repl reduction_graph
using ProblemReductions, Graphs
problem = IndependentSet(smallgraph(:diamond))
ProblemReductions.objectives(problem)
ProblemReductions.constraints(problem)
```

### Graph Topology

Model problems are often defined on graphs. When limiting a model problem to a specific graph topology, the hardness of the problem can be drastically different.
To handle this, we define the following graph types:

- [`SimpleGraph`](https://juliagraphs.org/Graphs.jl/dev/core_functions/simplegraphs/#Graphs.SimpleGraphs.SimpleGraph): A simple graph is an undirected graph with no self-loops or multiple edges between the same pair of vertices.
- [`HyperGraph`](@ref): A hypergraph is a generalization of a graph in which an edge can connect any number of vertices.
- [`UnitDiskGraph`](@ref): A unit disk graph is a graph in which vertices are placed in the Euclidean plane and edges are drawn between vertices that are within a fixed distance of each other. Similarly, we have an alias [`GridGraph`](@ref) for unit disk graphs with integer coordinates (i.e. vertices are placed on a grid).

![](./assets/graphtypes.svg)

To define a graph topology, the minimum required functions are: `vertices` and `edges`. More interfaces are specified in the [`Graphs`](https://juliagraphs.org/Graphs.jl/dev/) package.


## Reduction Rules

A problem reduction rule is a function that reduces a problem to another problem. By solving the target problem, we can extract the solution to the original problem. The reduction rule is defined as a function that takes an instance of the original problem and returns an [`AbstractReductionResult`](@ref) instance of the target problem.

- [`reduceto`](@ref): Reduce the source problem to a target problem of a specific type. Returns an [`AbstractReductionResult`](@ref) instance, which contains the target problem.
- [`target_problem`](@ref): Return the target problem of the reduction result.
- [`extract_solution`](@ref): Extract the solution to the target problem back to the original problem.

Optional functions include:
- [`extract_multiple_solutions`](@ref): Extract a set of solutions to the target problem back to the original problem. You may want to implement this when you want to make extracting multiple solutions faster.

The [`reduction_graph`](@ref) function returns the reduction graph of the problems that induced by the reduction rules defined in ProblemReductions:
```@repl reduction_graph
rgraph = ProblemReductions.reduction_graph()
rgraph.graph
rgraph.nodes
```
The number of rules is the same as the number of edges in the output graph.
Both the problem set, and the reduction rules are designed to be extensible, so that users can easily add new problems and reductions to the package.

It is worth noting that _the reduction graph changes whenever there is a new `reduceto` function is added, regardless it is in this package or by users_.
This is because the reduction graph checks all method tables of the `reduceto` function, and will automatically add new nodes and edges when a new problem type or reduction method is added.