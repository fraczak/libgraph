Graph    = require "../Graph"
dijkstra = require "./"
testGraphEdges =  require("./graph.json")

weight = (e) ->
    e.weight

console.log g = new Graph testGraphEdges, {0:"start", s:"detached"}

g.inHops    = dijkstra g
g.inWeight  = dijkstra g, weight

console.log "---------------------"
console.log "Dijkstra shortest paths: from '1' to '2'"
g.inHops[1]    = g.inHops.from 1
g.inWeight[1]  = g.inWeight.from 1
console.log " - in hops: distance: #{g.inHops[1].data[2].distance}, Edges:", g.inHops.from(1).edgesTo(2)
console.log " - in weight: distance: #{g.inWeight[1].data[2].distance}, Edges:", g.inWeight.from(1).edgesTo(2)

console.log "---------------------"
console.log "Dijkstra shortest paths: from '1' to 's'"
console.log dijkstra(g).from(1).edgesTo('s')

console.log "---------------------"
console.log "Dijkstra shortest path edges: from '1'"
console.log dijkstra(g).from(1).dagEdges()
