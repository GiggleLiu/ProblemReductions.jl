# Independent Set

## Problem Definition
Independent Set is a subset of vertices in a undirected graph such that all the vertices in the set are not connected by edges (or called not adjacent). The [`IndependentSet`] (@ref) problem is to find the independent set with maximum number of vertices.

## Interfaces
To define an `IndependentSet` problem, we need to specify the graph and possibily the weights associated with vertices. The weights are set as unit by default in the current version and might be generalized to arbitrary positive weights in the following development.
```@repl IndependentSet
using ProblemReductions, Graphs
graph = SimpleGraph(4)
add_edge!(graph, 1, 2) 
add_edge!(graph, 1, 3)
add_edge!(graph, 3, 4)
add_edge!(graph, 2, 3)
IS = IndependentSet(graph)
```

Besides, the required functions, [`variables`](@ref), [`flavors`](@ref), and [`energy`](@ref), and optional functions, [`findbest`](@ref), are implemented for the Independent Set problem.
```@repl IndependentSet
variables(IS)  # degrees of freedom
flavors(IS)  # flavors of the vertices
energy(IS, [1, 0, 0, 1]) # Positive sample: -(size) of an independent set
energy(IS, [0, 1, 1, 0]) # Negative sample: 0
findbest(IS, BruteForce())  # solve the problem with brute force
```