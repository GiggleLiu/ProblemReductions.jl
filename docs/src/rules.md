# Problem Reduction Rules

A problem reduction rule is a function that reduces a problem to another problem. By solving the target problem, we can extract the solution to the original problem. The reduction rule is defined as a function that takes an instance of the original problem and returns an [`AbstractReductionResult`](@ref) instance of the target problem.

## Interfaces
- [`reduceto`](@ref): Reduce the source problem to a target problem of a specific type. Returns an [`AbstractReductionResult`](@ref) instance, which contains the target problem.
- [`target_problem`](@ref): Return the target problem of the reduction result.
- [`extract_solution`](@ref): Extract the solution to the target problem back to the original problem.
- [`extract_multiple_solutions`](@ref): Extract a set of solutions to the target problem back to the original problem.

!!! note
    In some problems, some of the solutions to the target problem:

    - may correspond to mutilple solutions to the original problem, such as "SAT -> Dominating Set". If this is the case, the [`extract_solution`](@ref) will randomly pick one of the effective solutions; 
    - or may not correspond to a solution to the original problem, such as "SAT -> Circuit SAT". If this is the case, the [`extract_solution`](@ref) will return `nothing`.
    This is the motivation of desigining the [`extract_multiple_solutions`](@ref) interface.

Optional functions include:
- [`reduce_size`](@ref): Infer the size of the target problem from the source problem size.