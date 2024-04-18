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
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/GiggleLiu/ProblemReductions.jl",
    devbranch="main",
)
