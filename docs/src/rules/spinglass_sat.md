# CircuitSAT -> SpinGlass

In this tutorial, we will demonstrate how to use the Spinglass model to solve the circuit satisfiability problem.

We first define a simple [`Circuit`](@ref) using the [`@circuit`](@ref) macro. And then we convert the circuit to a [`CircuitSAT`](@ref) problem.

```@repl spinglass_sat
using ProblemReductions

circuit = @circuit begin
    c = x ∧ y
    d = x ∨ (¬c ∧ ¬z)
end
circuitsat = CircuitSAT(circuit)
variables(circuitsat)
circuitsat.symbols
```
The resulting `circuitsat` expands the expression to a list of simple clauses.
The variables are mapped to integers that pointing to the symbols that stored in the `symbols` field.

The we can convert the circuit to a [`SpinGlass`](@ref) problem using the [`reduceto`](@ref) function.
```@repl spinglass_sat
result = reduceto(SpinGlass{<:SimpleGraph}, circuitsat)
```
The resulting `result` is a `ReductionCircuitToSpinGlass` instance that contains the spin glass problem.

With the `result` instance, we can define a logic gadget that maps the spin glass variables to the circuit variables.
```@repl spinglass_sat
indexof(x) = findfirst(==(findfirst(==(x), circuitsat.symbols)), result.variables)
gadget = LogicGadget(result.spinglass, indexof.([:x, :y, :z]), [indexof(:d)])
tb = truth_table(gadget; variables=circuitsat.symbols[result.variables])
```
The `gadget` is a [`LogicGadget`](@ref) instance that maps the spin glass variables to the circuit variables. The [`truth_table`](@ref) function generates the truth table of the gadget.