# Circuit Satisfaction

A circuit can be defined with the [`@circuit`](@ref) macro as follows:
    
```@example CircuitSAT
using ProblemReductions

circuit = @circuit begin
    c = x ∧ y
    d = x ∨ (c ∧ ¬z)
end
```

The circuit can be converted to a [`CircuitSAT`](@ref) problem instance:
```@example CircuitSAT
sat = CircuitSAT(circuit)
```
Note that the circuit is converted to the static single assignment (SSA) form before the conversion.
The symbols are variables in the circuit to be assigned to `true` or `false`.

The circuit can be evaluated with the [`evaluate`](@ref) function:
```@example CircuitSAT
evaluate(sat, [true, false, true, true, false, false, true])
```
The return value is 0 if the assignment satisfies the circuit, otherwise, it is the number of unsatisfied clauses.
!!! note
    [`evaluate`](@ref) funciton returns lower values for better assignments.

To find all satisfying assignments, use the [`findbest`](@ref) function:
```@example CircuitSAT
findbest(sat, BruteForce())
```
Here, the [`BruteForce`](@ref) solver is used to find the best assignment.