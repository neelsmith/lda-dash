using Pkg
Pkg.activate(pwd())
Pkg.instantiate()

DASHBOARD_VERSION = "0.1"

using Dash
using CitableBase
using CitableText
using CitableCorpus
using Orthography

using CitableCorpusAnalysis

using TextAnalysis
using StatsBase, OrderedCollections

# Widgetize these:
iters = 1000
stopwords = ["the", "and", "of"]



assets = joinpath(pwd(), "dashboard", "assets")
app = dash(assets_folder = assets, include_assets_files=true)




apollodorus_url = "https://raw.githubusercontent.com/neelsmith/digitalmyth/main/texts/apollodorus.cex"
c =  fromcex(apollodorus_url, CitableTextCorpus, UrlReader)
lextokens = filter(t -> t.tokentype == LexicalToken(), Orthography.tokenize(c, simpleAscii()))
counts = countmap(map( t -> t.passage.text, lextokens)) |> OrderedDict
sorteddict = sort(counts, rev=true, byvalue = true)
k = 30
lda_tm(c, k; stopwords = stopwords, iters = iters)#, doclabels = labels)
app.layout = html_div() do
    html_div(className = "w3-container w3-light-gray w3-cell w3-mobile w3-border-left w3-border-right w3-border-gray",
    children = [dcc_markdown("*Dashboard version*: **$(DASHBOARD_VERSION)**")]
    ),

    html_h1("Topic modeling dashboard"),
    html_div(className="w3-container",
    children = [
        dcc_markdown("Did very much counting. Distinct toknes: $(length(counts))")
    ])
    
end

run_server(app, "0.0.0.0", debug=true)