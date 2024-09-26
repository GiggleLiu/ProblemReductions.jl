# Max Cut

## Problem Definition

Max Cut problem is defined on weighted graphs. The goal is to find a partition of the vertices into two sets such that the sum of the weights of the edges between the two sets is maximized.
## Interfaces

To initialize a [`MaxCut`](@ref), we need to specify the graph and the weights of the edges.

```@repl MaxCut
using ProblemReductions, Graphs
g = SimpleGraph(3)
for (i,j) in [(1,2),(1,3),(2,3)]
    add_edge!(g,i,j)
end # Add edges on the graph
maxcut = MaxCut(g,[1,2,3]) # specify the weights of the edges
```

Here the graph is a simple graph with 3 vertices and 3 edges. The weights of the edges are `[1,2,3]`.

Required functions and optional functions: [`set_parameters`](@ref), [`num_variables`](@ref) are implemented for this model.
```@repl MaxCut
mc = set_parameters(maxcut, [2,1,3]) # set the weights and get a new instance
num_variables(maxcut) # return the number of vertices
```