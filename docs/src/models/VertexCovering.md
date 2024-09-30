# Vertex Covering

## Problem Definition
A Vertex Cover is a subset of vertices in a graph, such that for an arbitrary edge, the subset includes at least one of the endpoints. The [`VertexCovering`](@ref) problem is to find the minimum vertex cover for a given graph.

## Interfaces
To define a `VertexCovering` problem, we need to specify the graph and the weights associated with edges. The weights are by default set as unit.
```@repl VertexCovering
using ProblemReductions, Graphs
graph = SimpleGraph(4)
add_edge!(graph, 1, 2)
add_edge!(graph, 1, 3)
add_edge!(graph, 3, 4)
add_edge!(graph, 2, 3)
weights = [1, 3, 1, 4]
VC= VertexCovering(graph, weights)
```

The required functions, `variables`, `evaluate`, and optional functions: `set_parameters` are implemented for the vertex covering problem.
```@repl VertexCovering
variables(VC)  # degrees of freedom
evaluate(VC, [1, 0, 0, 1]) # Negative sample
evaluate(VC, [0, 1, 1, 0]) # Positive sample
findbest(VC, BruteForce())  # solve the problem with brute force
VC02 = set_parameters(VC, [1, 2, 3, 4])  # set the weights of the subsets
```
!!! note
    The `evaluate` function returns the cost of a configuration. If the configuration is not a vertex cover, it returns a large number.