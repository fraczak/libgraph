ld = require "lodash"

generators = require "../generators/index.coffee"
Graph      = require "../Graph.coffee"

Ospf = require "./index.coffee"
wcf = require "./wcf.coffee"

countDems = Ospf.countDems

size = 80
ring = new Graph generators.ring size
console.log "Ring(#{size}), with #{Object.keys(ring.vertices).length} vertices and #{ring.edges.length} edges"

o = new Ospf ring
console.log "Total number of demands: #{countDems o.dems }"

edge = 0

dds = o.demsOnEdge edge

console.log "Number of demands on edge #{edge}: #{countDems dds}"

do (u = o.utilization([edge], dds)) ->
    edgeUtilization = u.edges[edge]
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

console.log " ---------- FAILURE ANALYSES ---------------"
for {topo,args} in [{topo:"cgrid", args:[4,3]}, {topo:"ring", args:[10]}, {topo:"circle", args:[10]}, {topo:"lattice",args:[5,3]}]
    console.log "   ---  #{topo}(#{args}):"
    g = new Graph generators[topo] args...
    o = new Ospf g
    console.log ({
        unfeasibleDems: Ospf.countDems utilization.unfeasibleDems
        failureSet
        utilization:utilization.edges
        max:ld.max utilization.edges 
        } for {failureSet,utilization} in wcf o, null, 2)
