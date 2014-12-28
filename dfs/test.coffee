Graph    = require "../Graph"
testGraphEdges =  require("./graph.json")
dfs      = require "./"

console.log g = new Graph testGraphEdges
console.log "-------- DFS rooted in '0':"
console.log dfs g, 0
