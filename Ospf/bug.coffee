
ld = require "underscore"

generators = require "../generators/index.coffee"
Graph      = require "../Graph.coffee"

Ospf = require "./index.coffee"

countDems = Ospf.countDems

square = new Graph generators.lattice 2, 2

ospf = new Ospf square, [{src:"v0.0", dst:"v1.1", traffic: 100},{src:"v1.0", dst:"v0.1", traffic: 50}]

console.log JSON.stringify square.edges
console.log JSON.stringify ospf.totalUtilization()

edges = [0,4] 

dems = ospf.demsOnEdges edges

console.log dems

result = ospf.utilization edges, dems

console.log result
