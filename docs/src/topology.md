# Graph Topology

* [`SimpleGraph`](https://juliagraphs.org/Graphs.jl/dev/core_functions/simplegraphs/#Graphs.SimpleGraphs.SimpleGraph): A simple graph is an undirected graph with no self-loops or multiple edges between the same pair of vertices.
* [`HyperGraph`](@ref): A hypergraph is a generalization of a graph in which an edge can connect any number of vertices.
* [`UnitDiskGraph`](@ref): A unit disk graph is a graph in which vertices are placed in the Euclidean plane and edges are drawn between vertices that are within a fixed distance of each other.
* [`GridGraph`](@ref): A grid graph is a graph in which vertices are placed on a grid and edges are drawn between vertices that are adjacent in the grid.

## Interfaces
The minimum required functions for a graph are:
- `vertices`: The vertices in the graph.
- `edges`: The edges in the graph.

Optional functions include:
- `ne`: The number of edges in the graph.
- `nv`: The number of vertices in the graph.

These interfaces are defined in the [`Graphs`](https://juliagraphs.org/Graphs.jl/dev/) package.