# Quadratic Unconstrained Binary Optimization

## Problem Definition
Quadratic Unconstrained Binary Optimization ([`QUBO`](@ref)) is a boolean optimization problem. The objective is to maximize or minimize the following quadratic form by varying $x$:
```math
y = x^T Q x
```
where $x$ is a $n$-dimensional boolean vector and $Q$ is a real square matrix. Without loss of generality, we focus on the minimization in this package. This problem is naturally similar with the spin glass problem on a hypergraph except that the flavors are $(0, 1)$ rather than $(-1,1)$. We can notice that $Q$ is the adjacency matrix, where the diagonal terms correspond to the external magnetic field.

## Interfaces
To define a `QUBO` problem, there are two ways:
* We can directly specify the $Q$ matrix;
* Or we can specify a simple graph and the weights associated with edges.
```@repl QUBO
using ProblemReductions, Graphs
# Matrix method
Q = [1. 0 0; 0 1 0; 0 0 1]
QUBO01 = QUBO(Q)
# Graph method
graph = SimpleGraph(3)
QUBO02 = QUBO(graph, Float64[], [1., 1., 1.])
```

Besides, the required functions, [`variables`](@ref), [`flavors`](@ref), and [`evaluate`](@ref), and optional functions, [`findbest`](@ref), are implemented for the [`QUBO`] problem.
```@repl QUBO
variables(QUBO01)  # degrees of freedom
variables(QUBO02)
flavors(QUBO01)  # flavors of the vertices
evaluate(QUBO01, [0, 1, 0])
evaluate(QUBO02, [0, 1, 0]) 
findbest(QUBO01, BruteForce())  # solve the problem with brute force
findbest(QUBO02, BruteForce()) 
```