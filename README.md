# ProblemReductions

[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://GiggleLiu.github.io/ProblemReductions.jl/dev/)
[![Build Status](https://github.com/GiggleLiu/ProblemReductions.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/GiggleLiu/ProblemReductions.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/GiggleLiu/ProblemReductions.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/GiggleLiu/ProblemReductions.jl)

This repository is for an ongoing project of open source promotion plan (OSPP) 2024: [A Julia package for problem reduction between computational hard problems](https://github.com/JuliaCN/ProjectIdeas/tree/main/problem-reduction).

This package is expected to be a tool for researchers to study the relationship between different computational hard problems. It defines a set of computational hard problems and provides a set of functions to reduce one problem to another. The package is designed to be extensible, so that users can easily add new reductions to the package.

On the release of the package, it is expected to cover all the problems that are used in [GenericTensorNetworks.jl](https://queracomputing.github.io/GenericTensorNetworks.jl/dev/), and will become a dependency of GenericTensorNetworks.jl. The listed problems are:
- (Maximal) Independent Set
- Max-Cut
- Graph Coloring
- Spin Glass
- Set Packing
- Set Covering
- Satifiability problem
- Dominating Set

## Developer note

You should have [Julia](https://julialang.org/) installed on your machine to run the following commands. Please refer to the [setup guide](https://book.jinguo-group.science/stable/chap2/julia-setup/) for installation.

To initialize the package environment, open a terminal and run the following command in the package directory:
```bash
make init   # or use `make update` to update
```

To run the tests, please type
```bash
make test
```

To serve the documentation locally, please type
```bash
make serve
```