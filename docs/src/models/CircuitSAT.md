# Circuit Satisfaction

## Problem Definition
A circuit can be defined with the [`@circuit`](@ref) macro as follows:
    
```@repl CircuitSAT
using ProblemReductions

circuit = @circuit begin
    c = x ∧ y
    d = x ∨ (c ∧ ¬z)
end
```

The circuit can be converted to a [`CircuitSAT`](@ref) problem instance:
```@repl CircuitSAT
sat = CircuitSAT(circuit)
sat.symbols
```
Note that the circuit is converted to the static single assignment (SSA) form, and the symbols are stored in the `symbols` field.
The symbols are variables in the circuit to be assigned to `true` or `false`.

## Interfaces
```@repl CircuitSAT
variables(sat)
flavors(sat)
```

The circuit can be evaluated with the [`evaluate`](@ref) function:
```@repl CircuitSAT
evaluate(sat, [true, false, true, true, false, false, true])
```
The return value is 0 if the assignment satisfies the circuit, otherwise, it is the number of unsatisfied clauses.
!!! note
    [`evaluate`](@ref) funciton returns lower values for satisfiable assignments.

To find all satisfying assignments, use the [`findbest`](@ref) function:
```@repl CircuitSAT
findbest(sat, BruteForce())
```
Here, the [`BruteForce`](@ref) solver is used to find the best assignment.