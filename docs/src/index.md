```@meta
CurrentModule = ProblemReductions
```

# ProblemReductions

Documentation for [ProblemReductions](https://github.com/GiggleLiu/ProblemReductions.jl).
This package is expected to be a tool for researchers to study the relationship between different computational hard problems. It defines a set of computational hard problems and provides a set of functions to reduce one problem to another. The package is designed to be extensible, so that users can easily add new reductions to the package.

## Framework

ProblemReductions defines a set of **model problems** and the **reduction rules** between them. In the following diagram, we use an arrow from problem A to problem B to indicate that there is a reduction rule from problem A to problem B.

![](./assets/reduction.svg)

The reduction rules define a directed graph, where the nodes are the problems and the edges are the reductions.
Problem A can be reduced to problem B if and only if there is a path from A to B.
This reduction may consist of multiple steps, and the reduction path may not be unique.

```@repl reduction_graph
using ProblemReductions
paths = reduction_paths(Factoring, SpinGlass);
length(paths)   # you may find multiple reduction paths
factoring = Factoring(2, 1, 3)  # define the factoring problem
res = reduceto(paths[1], factoring); # perform the reduction
problem_size(target_problem(res))
sol = findbest(target_problem(res), BruteForce()); # solve the target problem
extract_solution.(Ref(res), sol) # extract the solution to the original problem
```
Here, we try to solve a simple factoring problem $? \times ? = 3$.
The bit width of two inputs are 2 and 1, respectively.
This seemingly trivial problem reduces to an Ising model with 25 vertices.
Fortunately, it is still possible to solve it exactly using brute-force search.

A model problem is a subtype of [`AbstractProblem`](@ref). The following code lists all problems and reduction rules defined in ProblemReductions:
```@repl reduction_graph
ProblemReductions.concrete_subtypes(AbstractProblem)
ProblemReductions.reduction_graph().graph
```
The number of rules is the same as the number of edges in the output graph.
Both the problem set, and the reduction rules will be expanded in the future.

## Model Problems
A model problem is a subclass of [`AbstractProblem`](@ref) that defines the energy function of a computational problem.
Facts affecting the computational complexity classification of the problem also include the topology of the problem and the domain of the variables.

The required interfaces are:
- [`variables`](@ref): The degrees of freedoms in the problem.
    e.g. for the maximum independent set problems, they are the indices of vertices: 1, 2, 3...,
    while for the max cut problem, they are the edges.
- [`flavors`](@ref): A vector of integers as the flavors (or domain) of a degree of freedom.
    e.g. for the maximum independent set problems, the flavors are [0, 1], where 0 means the vertex is not in the set and 1 means the vertex is in the set.

- [`weights`](@ref): Energies associated with constraints.

- [`energy`](@ref): Energy of a given configuration.

Optional functions include:
- [`num_variables`](@ref): The number of variables in the problem.
- [`num_flavors`](@ref): The number of flavors in the problem.
- [`set_weights`](@ref): Change the weights for the `problem` and return a new problem instance.
- [`weight_type`](@ref): The data type of weights.
- [`findbest`](@ref): Find the best configurations in the computational problem.


### Graph Topology

![](./assets/graphtypes.svg)

Model problems are often defined on graphs. When limiting a model problem to a specific graph topology, the hardness of the problem can be drastically different.
To handle this, we define the following graph types:

- [`SimpleGraph`](https://juliagraphs.org/Graphs.jl/dev/core_functions/simplegraphs/#Graphs.SimpleGraphs.SimpleGraph): A simple graph is an undirected graph with no self-loops or multiple edges between the same pair of vertices.
- [`HyperGraph`](@ref): A hypergraph is a generalization of a graph in which an edge can connect any number of vertices.
- [`UnitDiskGraph`](@ref): A unit disk graph is a graph in which vertices are placed in the Euclidean plane and edges are drawn between vertices that are within a fixed distance of each other. Similarly, we have an alias [`GridGraph`](@ref) for unit disk graphs with integer coordinates (i.e. vertices are placed on a grid).

To define a graph topology, the minimum required functions are: `vertices` and `edges`. More interfaces are specified in the [`Graphs`](https://juliagraphs.org/Graphs.jl/dev/) package.


## Reduction Rules

A problem reduction rule is a function that reduces a problem to another problem. By solving the target problem, we can extract the solution to the original problem. The reduction rule is defined as a function that takes an instance of the original problem and returns an [`AbstractReductionResult`](@ref) instance of the target problem.

- [`reduceto`](@ref): Reduce the source problem to a target problem of a specific type. Returns an [`AbstractReductionResult`](@ref) instance, which contains the target problem.
- [`target_problem`](@ref): Return the target problem of the reduction result.
- [`extract_solution`](@ref): Extract the solution to the target problem back to the original problem.
- [`extract_multiple_solutions`](@ref): Extract a set of solutions to the target problem back to the original problem.

!!! note
    In some problems, some of the solutions to the target problem:

    - may correspond to mutilple solutions to the original problem, such as "SAT -> Dominating Set". If this is the case, the [`extract_solution`](@ref) will randomly pick one of the effective solutions; 
    - or may not correspond to a solution to the original problem, such as "SAT -> Circuit SAT". If this is the case, the [`extract_solution`](@ref) will return `nothing`.
    This is the motivation of desigining the [`extract_multiple_solutions`](@ref) interface.

Optional functions include:
- [`reduce_size`](@ref): Infer the size of the target problem from the source problem size.