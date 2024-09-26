using ProblemReductions
using Documenter
using Literate

# Literate
for each in readdir(pkgdir(ProblemReductions, "examples"))
    input_file = pkgdir(ProblemReductions, "examples", each)
    endswith(input_file, ".jl") || continue
    @info "building" input_file
    output_dir = pkgdir(ProblemReductions, "docs", "src", "generated")
    Literate.markdown(input_file, output_dir; name=each[1:end-3], execute=false)
end

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
            "models/Coloring.md",
            "models/Factoring.md",
            "models/MaxCut.md",
            "models/SpinGlass.md"          
        ],
        "Rules" => [
            "rules/spinglass_sat.md",
        ],
        "Examples" => [
            "generated/material_compute.md",
            "generated/Ising.md",
        ],
        "Reference" => "ref.md",
    ],
)

deploydocs(;
    repo="github.com/GiggleLiu/ProblemReductions.jl",
    devbranch="main",
)
