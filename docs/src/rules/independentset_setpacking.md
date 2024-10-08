# Independent Set -> Set Packing

In this tutorial, we will demonstrate how to reduce the [`IndependentSet`] (@ref) problem to the [`SetPacking`] (@ref) problem and how to extract solutions back to the original problem.

## Reduction Framework
Given an undirected graph $G=(V,E)$ and parameter $k$, we can have an instance of the [`IndependentSet`] (@ref) problem $(G, k)$. we aim to generate a corresponding [`SetPacking`] (@ref) instance $(U, S, k)$ (where $U$ is the union set, $S$ is the set of subsets and parameter $k$ is the required set packing size).

- Step-0: $k$ are the same;
- Step-1: Each edge $(u,v)\in E$ -> Create an element $x_{u,v}$ in $U$;
- Step-2: Each vertex $v \in V$ -> Create a subset $\{S_{u,v}|(u,v)\in E \}$.

It can be proven that:

- The instance $(G,k)$ is an yes-instance if and only if generated $(U,S,k)$ is an yes-instance;
- This transformation is within polynomial time.

## Construct Reduction
We can firstly define a [`IndependentSet`] (@ref) problem over a simple graph with $4$ vertices.
```@repl independentset_setpacking
using ProblemReductions, Graphs
graph = SimpleGraph(4)
add_edge!(graph, 1, 2) 
add_edge!(graph, 1, 3)
add_edge!(graph, 3, 4)
add_edge!(graph, 2, 3)
IS = IndependentSet(graph)
```
Then the reduction [`ReductionIndependentSetToSetPacking`] (@ref) can be easily constructed by the [`reduceto`](@ref) function.
```@repl independentset_setpacking
result = reduceto(SetPacking, IS)
```
The target [`SetPacking`] (@ref) problem can be accessed by the `target` field:
```@repl independentset_setpacking
SP = result.target
```

## Extract Solutions
We can extract solutions from the target [`SetPacking`] (@ref) problem either by extracting individual solutions via [`extract_solution`] (@ref) or extracting mutilple solutions via [`extract_multiple_solutions`] (@ref).
```@repl independentset_setpacking
sol_SP = findbest(SP, BruteForce())
sol_extract_single = Set( unique( extract_solution.(Ref(result), sol_SP) ) )
sol_extract_mutilple = Set( extract_multiple_solutions(result, sol_SP) )
```
We can find that these extracted solutions indeed match with the solutions to the original [`IndependentSet`] (@ref) problem.
```@repl independentset_setpacking
sol_IS = findbest(IS, BruteForce())
```