# Dominating Set

## Problem Definition
Dominaing Set is a subset of vertices in a undirected graph such that all the vertices in the set are either in the dominating set or in its first-order neighborhood. The [`DominatingSet`] (@ref) problem is to find the dominating set with minimum number of vertices.

## Interfaces
To define an `DominatingSet` problem, we need to specify the graph and possibily the weights associated with vertices. The weights are set as unit by default in the current version and might be generalized to arbitrary positive weights in the following development.
```@repl DominatingSet
using ProblemReductions, Graphs
graph = SimpleGraph(5)
add_edge!(graph, 1, 2)
add_edge!(graph, 2, 3)
add_edge!(graph, 3, 4)
add_edge!(graph, 4, 5)
DS = DominatingSet(graph)
```

Besides, the required functions, [`variables`](@ref), [`flavors`](@ref), and [`evaluate`](@ref), and optional functions, [`findbest`](@ref), are implemented for the Independent Set problem.
```@repl DominatingSet
variables(DS)  # degrees of freedom
flavors(DS)  # flavors of the vertices
evaluate(DS, [0, 1, 0, 1, 0]) # Positive sample: (size) of a dominating set
evaluate(DS, [0, 1, 1, 0, 0]) # Negative sample: number of vertices
findbest(DS, BruteForce())  # solve the problem with brute force
```