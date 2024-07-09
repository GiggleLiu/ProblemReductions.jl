# Model Problem

A model problem is a subclass of [`AbstractProblem`](@ref) that defines the energy function of a graph problem.

## Interfaces
Required functions include:
- [`variables`](@ref): The degrees of freedoms in the graph problem.
    e.g. for the maximum independent set problems, they are the indices of vertices: 1, 2, 3...,
    while for the max cut problem, they are the edges.
- [`flavors`](@ref): A vector of integers as the flavors (or domain) of a degree of freedom.
    e.g. for the maximum independent set problems, the flavors are [0, 1], where 0 means the vertex is not in the set and 1 means the vertex is in the set.

- [`terms`](@ref): Variables that carrying local energies (or weights) in the graph problem.
- [`get_weights`](@ref): Energies associated with terms. Returns the weights for the `i`-th term if a second argument is provided.

- [`evaluate`](@ref): Evaluate the energy of a given configuration.

Optional functions include:
- [`num_variables`](@ref): The number of variables in the graph problem.
- [`num_flavors`](@ref): The number of flavors in the graph problem.
- [`chweights`](@ref): Change the weights for the `problem` and return a new problem instance.
- [`num_terms`](@ref): The number of terms in the graph problem.
- [`weight_type`](@ref): The data type of weights.
- [`findbest`](@ref): Find the best configurations in the graph problem.