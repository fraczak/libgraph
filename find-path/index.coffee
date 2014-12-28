dfs = require "../dfs"

# returns [e1,e2,e3] - a path from src to dst
#   or undefined if there is no path
findPath = (graph, src, dst) ->
    dfsData = dfs graph, src
    return unless dfsData.visit[dst]
    edges = graph.edges
    lastEdge = dfsData.visit[dst].treeEdge
    res = []
    while (lastEdge isnt undefined)
        res.unshift(lastEdge)
        lastEdge = dfsData.visit[edges[lastEdge].src].treeEdge
    res

module.exports = findPath
