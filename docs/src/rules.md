# Problem Reduction Rules

A problem reduction rule is a function that reduces a problem to another problem. By solving the target problem, we can extract the solution to the original problem. The reduction rule is defined as a function that takes an instance of the original problem and returns an [`AbstractReductionResult`](@ref) instance of the target problem.

## Interfaces
- [`reduceto`](@ref): Reduce the source problem to a target problem of a specific type. Returns an [`AbstractReductionResult`](@ref) instance, which contains the target problem.
- [`target_problem`](@ref): Return the target problem of the reduction result.
- [`extract_solution`](@ref): Extract the solution of the target problem to the original problem.

Optional functions include:
- [`reduction_complexity`](@ref): The computational complexity of the reduction rule.