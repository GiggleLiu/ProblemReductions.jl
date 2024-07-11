using ProblemReductions
using Documenter

DocMeta.setdocmeta!(ProblemReductions, :DocTestSetup, :(using ProblemReductions); recursive=true)

makedocs(;
    modules=[ProblemReductions],
    authors="GiggleLiu <cacate0129@gmail.com> and contributors",
    sitename="ProblemReductions.jl",
    format=Documenter.HTML(;
        canonical="https://GiggleLiu.github.io/ProblemReductions.jl",
        edit_link="main",
        assets=String[],
    ),
    doctest = ("doctest=true" in ARGS),
    pages=[
        "Home" => "index.md",
        "Interfaces" => ["models.md", "topology.md", "rules.md"],
        "Models" => [
            "models/CircuitSAT.md",
            "models/SpinGlass.md"
        ],
        "Rules" => [
            "rules/spinglass_sat.md",
        ],
        "Reference" => "ref.md",
    ],
)

deploydocs(;
    repo="github.com/GiggleLiu/ProblemReductions.jl",
    devbranch="main",
)
