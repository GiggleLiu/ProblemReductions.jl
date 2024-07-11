# CircuitSAT -> SpinGlass

In this tutorial, we will demonstrate how to use the Spinglass model to solve the circuit satisfiability problem.

We first define a simple [`Circuit`](@ref) using the [`@circuit`](@ref) macro. And then we convert the circuit to a [`CircuitSAT`](@ref) problem.

```@repl spinglass_sat
using ProblemReductions

circuit = @circuit begin
    c = x ∧ y
    d = x ∨ (c ∧ ¬z)
end
circuitsat = CircuitSAT(circuit)
```
The resulting `circuitsat` expands the expression to a list of simple clauses.

The we can convert the circuit to a [`SpinGlass`](@ref) problem using the [`reduceto`](@ref) function.
```@repl spinglass_sat
result = reduceto(SpinGlass, circuitsat)
indexof(x) = findfirst(==(x), result.variables)
gadget = LogicGadget(result.spinglass, indexof.([:x, :y, :z]), [indexof(:d)])
tb = truth_table(gadget; result.variables)
```