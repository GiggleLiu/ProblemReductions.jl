# Set Covering

## Problem Definition
The [`SetCovering`](@ref) problem is a combinatorial optimization problem that arises in many practical applications. It's in the class of NP-Complete and heuristic or approximation algorithms are often used to find solutions.

## Interfaces
Initialize a `SetCovering` instance needs to specify the subsets and the weights of the subsets. 
```@repl SetCovering
using ProblemReductions
subsets = [[1, 2, 3], [2, 4], [1, 4]]
weights = [1, 2, 3]
setcovering = SetCovering(subsets, weights)
```
Use 2-dimensional vector to represent the subsets.

The required functions, `variables`, `evaluate`, and optional functions:`set_parameters` are implemented for the set covering problem.
```@repl SetCovering
variables(setcovering)  # degrees of freedom
evaluate(setcovering, [1, 0, 1])  # cost of a configuration
evaluate(setcovering, [0, 1, 1]) 
sc = set_parameters(setcovering, [1, 2, 3])  # set the weights of the subsets
```
!!! note
    The `evaluate` function returns the cost of a configuration. If the configuration is not a set cover, it returns a large number.


