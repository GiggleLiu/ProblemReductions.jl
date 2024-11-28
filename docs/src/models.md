# Problems zoo

```@index
Pages = ["models.md"]
```

```@autodocs
Modules = [ProblemReductions]
Filter = t -> (typeof(t) === DataType || typeof(t) === UnionAll) && (t <: ProblemReductions.AbstractProblem)
```
