graph = require "./Graph"
bf = require "./bellman-ford"
dijkstra = require "./dijkstra"
Dijkstra = require "./Dijkstra"
dfs = require "./dfs"
findPath = require "./find-path"
maxFlow = require "./max-flow"

len = (e) ->
    e.weight

# console.log g = new graph require "./graph.json"
# console.log "Bellman-Ford"
# console.log JSON.stringify bf g, len
# console.log "Dijkstra (from vertex '0')"
# console.log JSON.stringify dijkstra g, '0', len
# console.log "---------------------"
# console.log "Dijkstra Path (from vertex '1' to '2')"
# console.log JSON.stringify (new Dijkstra g, '1', len).getPathTo '2'

# console.log "Dijkstra Dag (from vertex '1' to '2')"
# console.log JSON.stringify (new Dijkstra g, '1', len).getDagTo '2'

# console.log "DFS from '0'"
# console.log JSON.stringify dfs g, '0'
# console.log "Path from '0' to '3'"
# console.log JSON.stringify findPath g, '0', '3'
# console.log "Path from '2' to '2'"
# console.log JSON.stringify findPath g, '2', '2'
# console.log "Max-Flow 0->3"
# console.log JSON.stringify maxFlow g, '0', '3', len
# console.log "Max-Flow 0->1"
# console.log JSON.stringify maxFlow g, '0', '1', len


# g2 = new graph require "./graph2.json"
# console.log "Bellman-Ford"
# console.log JSON.stringify bf g2, len

###############
Cost = require "./Cost"


cost = new Cost Cost.e.cost, Cost.e.demand
cost.go ->
    console.log JSON.stringify cost.cost

