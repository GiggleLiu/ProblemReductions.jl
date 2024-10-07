# Spin Glass

## Problem Definition
Spin Glass is a type of disordered magnetic system that exhibits a glassy behavior. The Hamiltonian of the system on a simple graph $G$ is given by
```math
H(G, \sigma) = \sum_{(i,j) \in E(G)} J_{ij} \sigma_i \sigma_j + \sum_{i \in V(G)} h_i \sigma_i
```
where $J_{ij} \in \mathbb{R}$ is the coupling strength between spins $i$ and $j$, $h_i \in \mathbb{R}$ is the external field on spin $i$, and $\sigma_i$ is the spin variable that can take values in $\{-1, 1\}$ for spin up and spin down, respectively.

This definition naturally extends to the case of a [`HyperGraph`](@ref):
```math
H(G, \sigma) = \sum_{e \in E(G)} J_{e} \prod_k\sigma_k,
```
where $J_e$ is the coupling strength associated with hyperedge $e$, and the product is over all spins in the hyperedge.

## Interfaces

To define a [`SpinGlass`](@ref) problem, we need to specify the graph, the coupling strength $J_{ij}$, and possibly the external field $h_i$ for each spin $i$.

```@repl spinglass
using ProblemReductions, ProblemReductions.Graphs

graph = smallgraph(:petersen)
J = rand([1, -1], ne(graph))  # coupling strength
h = rand([1, -1], nv(graph))  # external field
spinglass = SpinGlass(graph, J, h)  # Define a spin glass problem
```
Here, we also define an external field $h_i$ for each spin $i$. The resulting spin glass problem is defined on a [`HyperGraph`](@ref), where external fields are associated with hyperedges connecting single spins.


The required functions, [`variables`](@ref), [`flavors`](@ref), and [`energy`](@ref), and optional functions, [`findbest`](@ref), are implemented for the spin glass problem.

```@repl spinglass
variables(spinglass)  # degrees of freedom
flavors(spinglass)  # flavors of the spins
energy(spinglass, [-1, 1, 1, -1, 1, 1, 1, -1, -1, 1])  # energy of a configuration
findbest(spinglass, BruteForce())  # solve the problem with brute force
```