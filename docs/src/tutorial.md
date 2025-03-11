# Tutorial

## Understanding Constraint Satisfaction Problems in ProblemReductions

This tutorial explains how to work with constraint satisfaction problems using the ProblemReductions package in Julia.

### Basic Setup
First, let's import the required packages and create a simple problem:
```@repl problem
using ProblemReductions, Graphs
problem = IndependentSet(smallgraph(:diamond))
```
This creates an Independent Set problem based on a diamond-shaped graph.

### Problem Properties
You can query various properties of the problem:

**1. Basic properties**
```@repl problem
num_variables(problem)  # number of variables
num_flavors(problem)  # number of flavors of each variable
problem_size(problem)  # size of the problem
```

**2. Weights (for weighted problems)**
```@repl problem
ProblemReductions.weights(problem)  # weights of the problem

ProblemReductions.set_weights(problem, [1, 2, 2, -1, -1, -2])  # set the weights of the problem
```

**3. Objectives and Constraints**
```@repl problem
ProblemReductions.objectives(problem)   # View the objective functions
ProblemReductions.constraints(problem)  # View the constraints
ProblemReductions.energy_mode(problem)  # View the energy mode of the problem
```

#### Remarks
- All [`ConstraintSatisfactionProblem`](@ref)s use [`objectives`](@ref) and [`constraints`](@ref) to define the problem.
- The [`constraints`](@ref) returns a vector of local constraints. Each local constraint is a boolean function of the variables. `true` means the constraint is satisfied by the current assignment to local variables.
- The energy is defined as `-solution_size` if `energy_mode(problem) == LargerSizeIsBetter()` and `solution_size` if `energy_mode(problem) == SmallerSizeIsBetter()`. The energy is infinity if the solution is invalid.

### Working with Solutions
You can evaluate different solutions (configurations) using these methods:

**1. Single Solution Evaluation**

```@repl problem
solution_size(problem, [1, 0, 1, 0])  # Calculate solution size
energy(problem, [1, 0, 1, 0])         # Calculate energy
```
The solution size is defined as the sum of the sizes of the variables. It returns a [`SolutionSize`](@ref) object, which has two fields:
  - `size`: the size of the solution
  - `is_valid`: whether the solution satisfies the constraints

**2. Multiple Solutions Evaluation (faster than multiple single evaluations)**
```@repl problem
solution_size_multiple(problem, [[1, 0, 0, 0], [0, 1, 0, 1]]) # Evaluate multiple configurations
```

**3. Finding the Optimal Solution**
```@repl problem
ProblemReductions.findbest(problem, BruteForce()) # Find the best configuration using brute force
```

#### Remarks
- Configuration Format: Solutions are represented as vectors of integers in the range of `0:num_flavors(problem)-1`, where each element represents a variable's state.
- Optimization: The [`findbest`](@ref) method allows you to find optimal solutions using different algorithms (like [`BruteForce`](@ref) in this example). Alternatively, you can use the `GTNSolver` in the `GenericTensorNetworks` package to find optimal solutions using tensor network methods.

This API provides a comprehensive toolkit for defining, manipulating, and solving constraint satisfaction problems in Julia.