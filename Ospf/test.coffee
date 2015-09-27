ld = require "lodash"

generators = require "../generators/index.coffee"
Graph      = require "../Graph.coffee"

Ospf = require "./index.coffee"

countDems = (dems) ->
    ld(dems)
    .map (dests) -> dests.length
    .reduce (r,n) -> r + n

circle = new Graph generators.ring 350

o = new Ospf circle

console.log "Total number of demands: #{countDems o.dems }"

edge = 0

dds = o.demsOnEdge edge

console.log "Number of demands on 1: #{countDems dds}"
