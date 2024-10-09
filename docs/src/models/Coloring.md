# Vertex Coloring

## Problem Definition
The Vertex Coloring (Coloring) problem is defined on a simple graph. Given k kinds of colors, we need to determine whether we can color all vertices on the graph such that no two adjacent vertices share the same color.
## Interfaces

To initialize a [`Coloring`](@ref) problem, we need to first define a simple graph and decide the number of colors.

```@repl Coloring
using ProblemReductions, Graphs
g = smallgraph(:petersen) # define a simple graph, petersen as example

coloring = Coloring{3}(g)
```
We create a petersen graph and take 3 colors here to initialize a Coloring Problem. 

Functions [`variables`](@ref), [`flavors`](@ref), [`num_flavors`](@ref), [`weights`](@ref) and [`set_weights`](@ref) are implemented for `Coloring` model. 
```@repl Coloring
variables(coloring)
flavors(coloring)
```

Also, [`energy`](@ref) and [`is_vertex_coloring`](@ref) is also implemented.
```@repl Coloring
is_vertex_coloring(coloring.graph,[1,2,3,1,3,2,1,2,3,1]) #random assignment
```