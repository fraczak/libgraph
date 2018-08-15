ld = require "underscore"

generators = require "../generators/index.coffee"
Graph      = require "../Graph.coffee"

Igp = require "./index.coffee"

size = 80
ring = new Graph generators.ring size
console.log "Ring(#{size}), with #{Object.keys(ring.vertices).length} vertices and #{ring.edges.length} edges"

o = new Igp ring
console.log "Total number of demands: #{o.demands.length}"

edge = 0

dds = o.demandsOnEdge o.graph.edges[edge]

dds = dds.onDemands

console.log "Number of demands on edge #{edge}: #{dds.length}"


do (u = o.utilizationOnEdges([edge])) ->
    edgeUtilization = u[edge]
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

for {topo,args} in [{topo:"cycle",args:[60]}, {topo:"grid",args:[14,8]}]
    g = new Graph generators[topo] args...
    console.log " - #{topo}(#{args}), with #{Object.keys(g.vertices).length} vertices and #{g.edges.length} edges"

    o = new Igp g
    console.log "Total number of demands: #{o.demands.length}"

    console.log "Number of unfeasible demands :", o.utilization().unfeasible.length


