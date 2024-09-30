# Satisfiability

## Problem Definition
[`Satisfiability`] (@ref) (also called SAT) problem is to find the boolean assignment that satisfies a Conjunctive Normal Form (CNF). A tipical CNF would look like:
```math
\left(l_{11} \vee \ldots \vee l_{1 n_1}\right) \wedge \ldots \wedge\left(l_{m 1} \vee \ldots \vee l_{m n_m}\right)
```
where literals are joint by $\vee$ to form clauses and clauses are joint by $\wedge$ to form a CNF.

We should note that all the SAT problem problem can be reduced to the $3$-SAT problem and it can be proved that $3$-SAT is NP-complete.

## Interfaces
To define an `Satisfiability` problem, we need to construct boolean variables, clauses, CNF.
```@repl Satisfiability
using ProblemReductions
bv1 = BoolVar("x")
bv2 = BoolVar("y")
bv3 = BoolVar("z", true)    
clause1 = CNFClause([bv1, bv2, bv3])
clause2 = CNFClause([BoolVar("w"), bv1, BoolVar("x", true)])
cnf_test = CNF([clause1, clause2])
sat_test = Satisfiability(cnf_test)
```

Besides, the required functions, [`variables`](@ref), [`flavors`](@ref), and [`evaluate`](@ref), and optional functions, [`findbest`](@ref), are implemented for the Satisfiability problem.
```@repl Satisfiability
variables(sat_test)  # degrees of freedom
flavors(sat_test)  # flavors of the literals
evaluate(sat_test, [1, 1, 1, 1]) # Positive sample
evaluate(sat_test, [0, 0, 1, 0]) # Negative sample
findbest(sat_test, BruteForce())  # solve the problem with brute force
```

## Relation with the Circuit SAT
The circuit SAT can include other boolean expression beyond CNF such as Disjunctive Normal Form (DNF). However, all the boolean expressions can be generally transformed to CNF, so the circuit SAT is "equivalent" with SAT.