trieFactory = require "trie"

pad = (number, size) ->
    res = ""+number
    while (res.length < size)
        res = "0" + res
    return res if res.length is size
    throw "Number #{number} is not correctly stringified"

# generates the Dijkstra data-structure for a given 'graph' and
# a 'weightFn'.
# Usage:
#     Graph = require "Graph"
#     dijkstra = require "Graph/dijkstra"
#     myGraph = new Graph [{src:0,dst:1},{src:0,dst:2},{src:1,dst:2}]
#     myGraph.inHops = dijkstra myGraph, -> 1
#     console.log myGraph.inHops.from(0).edgesTo(2)
dijkstra = (graph, weightFn) ->
    edges = graph.edges
    weightFn ?= -> 1
    toStrFn = do ->
        maxLen = 0
        for e in edges
            maxLen = maxLen + weightFn e
        maxLen = (""+maxLen).length
        (x) ->
            pad x.distance, maxLen
    return {
        weightFn: weightFn
        from: (src) ->
            data = {}
            queue = trieFactory toStrFn
            data[src] = last:[], distance:0
            for i in graph.src[src] or []
                queue.add i: i, distance: weightFn edges[i]
            while (queue.size() > 0)
                elem = queue.getNth 0
                queue.del elem
                {i,distance} = elem
                v = edges[i].dst
                if (not data[v])
                    data[v] = last: [i], distance: distance
                    for ee in graph.src[v] or []
                        queue.add i: ee, distance: distance + weightFn edges[ee]
                else if data[v].distance is distance
                    data[v].last.push i
            edgesTo = (dst) ->
                marker = {}
                return unless data[dst]
                queue = [].concat data[dst].last
                pathEdges = []
                while queue.length > 0
                    e = queue.shift()
                    if not marker[e]
                        marker[e] = true
                        pathEdges.push e
                        queue = queue.concat data[edges[e].src].last
                pathEdges
            return {src,data,edgesTo}
    }

module.exports = dijkstra
