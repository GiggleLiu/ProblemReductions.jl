# ProblemReductions

[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://GiggleLiu.github.io/ProblemReductions.jl/dev/)
[![Build Status](https://github.com/GiggleLiu/ProblemReductions.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/GiggleLiu/ProblemReductions.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/GiggleLiu/ProblemReductions.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/GiggleLiu/ProblemReductions.jl)

`ProblemReductions` is a package for the reduction (or transformation) between computational hard problems. Although the reduction is a common concept in the field of computational complexity, every textbook on this topic defines its own set of problems and reduction rules. Unfortunately, these rules are not directly accessible to the public, especially for people in fields such as quantum many-body physics and statistical physics. This package aims to collect a set of well-known problems and their reductions in one place, and provide a unified interface to access them. We hope this will lower the barrier for researchers to enter this fascinating field.

This package is supported by the open source promotion plan (OSPP) 2024: [A Julia package for problem reduction between computational hard problems](https://github.com/JuliaCN/ProjectIdeas/tree/main/problem-reduction).


## Installation

<p>
GenericTensorNetworks is a &nbsp;
    <a href="https://julialang.org">
        <img src="https://raw.githubusercontent.com/JuliaLang/julia-logo-graphics/master/images/julia.ico" width="16em">
        Julia Language
    </a>
    &nbsp; package. To install ProblemReductions,
    please <a href="https://docs.julialang.org/en/v1/manual/getting-started/">open
    Julia's interactive session (known as REPL)</a> and press the <kbd>]</kbd> key in the REPL to use the package mode, and then type:
</p>

```julia
pkg> add ProblemReductions
```

To update, just type `up` in the package mode.

## Questions and Contributions

Just open an [issue](https://github.com/GiggleLiu/ProblemReductions.jl/issues) if you encounter any problems, or have any feature request.
