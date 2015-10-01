ld = require "lodash"

generators = require "../generators/index.coffee"
Graph      = require "../Graph.coffee"

Ospf = require "./index.coffee"

countDems = Ospf.countDems

size = 80
ring = new Graph generators.ring size
console.log "Ring(#{size}), with #{Object.keys(ring.vertices).length} vertices and #{ring.edges.length} edges"

o = new Ospf ring
console.log "Total number of demands: #{countDems o.dems }"

edge = 0

dds = o.demsOnEdge edge

console.log "Number of demands on edge #{edge}: #{countDems dds}"

for edgeUtilization in [
    o.utilization([edge], dds)[edge]
    ]
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

for {topo,args} in [{topo:"circle",args:[60]}, {topo:"grid",args:[3,5]}]
    g = new Graph generators[topo] args...
    console.log " - #{topo}(#{args}), with #{Object.keys(g.vertices).length} vertices and #{g.edges.length} edges"

    o = new Ospf g
    console.log "Total number of demands: #{countDems o.dems }"

    console.log JSON.stringify o.totalUtilization()

