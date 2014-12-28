Graph = require "../Graph"
bf    = require "./"

len = (e) ->
    e.weight

for file in [
    './graph.json', './graph2.json', './graph3.json']
    console.log "------------ #{file} -----------------"
    console.log g = new Graph require file
    console.log " * bellman-ford: "
    res = (bf g, len)
    for i in Object.keys(g.vertices)
        console.log "From #{i} to:"
        console.log res[i]

try
    console.log g = new Graph require './graph4.json'
    console.log " * bellman-ford: "
    res = (bf g, len)
    for i in Object.keys(g.vertices)
        console.log "From #{i} to:"
        console.log res[i]
catch e
    console.log "Exception:", e
    console.log " ... that's ok, we expected it"
