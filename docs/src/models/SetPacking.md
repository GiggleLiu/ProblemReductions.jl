# Set Packing

## Problem Definition
A packing is a set of sets where each set is pairwise disjoint from each other. The [`SetPacking`] (@ref) problem is to find the maximum packing for a given union and a set of subsets.

## Interfaces
To define a `SetPacking` problem, we need to specify the set of subsets and possibily the weights associated with these subsets. The weights are set as unit by default in the current version and might be generalized to arbitrary positive weights in the following development. Besides, the elements would be automatically counted by the construction function. 
```@repl SetPacking
using ProblemReductions
sets = [[1, 2, 5], [1, 3], [2, 4], [3, 6], [2, 3, 6]]
SP = SetPacking(sets)
```

Then, the required functions, [`variables`](@ref), [`flavors`](@ref), and [`evaluate`](@ref), and optional functions, [`findbest`](@ref), are implemented for the Set Packing problem.
```@repl SetPacking
variables(SP)  # degrees of freedom
flavors(SP)  # flavors of the subsets
evaluate(SP, [1, 0, 0, 1, 0]) # Positive sample: -(size) of a packing
evaluate(SP, [1, 0, 1, 1, 0]) # Negative sample: 0
findbest(SP, BruteForce())  # solve the problem with brute force
```