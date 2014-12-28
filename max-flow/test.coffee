Graph    = require "../Graph"
maxFlow  = require "./"
testGraphEdges =  require("./graph.json")

console.log g = new Graph testGraphEdges

flowFn = (e) ->
    e.weight

console.log "Max-Flow 0->3"
console.log maxFlow g, '0', '3', flowFn
console.log "Max-Flow 0->1"
console.log maxFlow g, '0', '1', flowFn
console.log "Max-Flow 3->13"
console.log maxFlow g, '3', '13', flowFn
console.log "Max-Flow 14->1"
console.log maxFlow g, '14', '1', flowFn


