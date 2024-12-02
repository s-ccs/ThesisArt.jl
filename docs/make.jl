using ThesisArt
using Documenter

DocMeta.setdocmeta!(ThesisArt, :DocTestSetup, :(using ThesisArt); recursive = true)

const page_rename = Dict("developer.md" => "Developer docs") # Without the numbers
const numbered_pages = [
    file for file in readdir(joinpath(@__DIR__, "src")) if
    file != "index.md" && splitext(file)[2] == ".md"
]

makedocs(;
    modules = [ThesisArt],
    authors = "Benedikt Ehinger <thesisart@benediktehinger.de>",
    repo = "https://github.com/s-ccs/ThesisArt.jl/blob/{commit}{path}#{line}",
    sitename = "ThesisArt.jl",
    format = Documenter.HTML(; canonical = "https://s-ccs.github.io/ThesisArt.jl"),
    pages = ["index.md"; numbered_pages],
)

deploydocs(; repo = "github.com/s-ccs/ThesisArt.jl")
