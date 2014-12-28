Graph    = require "../Graph"
Dijkstra = require "./Dijkstra"

len = (e) ->
    e.weight

console.log g = new Graph require "./graph.json"
console.log "Dijkstra (from vertex '0')"
console.log JSON.stringify (new Dijkstra g, '0', len).data
console.log "---------------------"
console.log "Dijkstra Path (from vertex '1' to '2')"
console.log JSON.stringify (new Dijkstra g, '1', len).getEdgesTo '2'

console.log "Dijkstra Dag (from vertex '1' to '2')"
console.log JSON.stringify (new Dijkstra g, '1', len).getDagTo '2'

