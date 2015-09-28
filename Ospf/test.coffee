ld = require "lodash"

generators = require "../generators/index.coffee"
Graph      = require "../Graph.coffee"

Ospf = require "./index.coffee"

countDems = (dems) ->
    ld(dems)
    .map (dests) -> dests.length
    .reduce (r,n) -> r + n

size = 60

ring = new Graph generators.ring size
console.log "Ring(#{size}), with #{Object.keys(ring.vertices).length} vertices and #{ring.edges.length} edges"

o = new Ospf ring

console.log "Total number of demands: #{countDems o.dems }"

edge = 0

dds = o.demsOnEdge edge

console.log "Number of demands on edge #{edge}: #{countDems dds}"

edgeUtilization = o.edgeUtilization edge

dem_to_show = 3
res_str = do  ->
    res_size = Object.keys(edgeUtilization).length
    totalUtilization = 0
    for key,val of edgeUtilization
        totalUtilization += val
        dems = (" #{key} with traffic #{val}[KB]" for key,val of edgeUtilization)
            .splice(0,dem_to_show)
            .concat(" ... " if res_size > dem_to_show)
    "  Edge #{edge} carries #{totalUtilization}[KB] in total:\n    #{dems}"

console.log [
    " Done:"
].concat(res_str,"------------").join("\n")
