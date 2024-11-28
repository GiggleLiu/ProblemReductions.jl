# Reference

```@index
Pages = ["ref.md"]
```

```@autodocs
Modules = [ProblemReductions]
Filter = t -> !((typeof(t) === DataType || typeof(t) === UnionAll) && (t <: ProblemReductions.AbstractProblem))
```