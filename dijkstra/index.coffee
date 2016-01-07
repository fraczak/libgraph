trieFactory = require "trie-array"

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
        maxPrec = 0
        for e in edges
            prec = weightFn(e).toString().split(".")[1]?.length or 0
            maxPrec = prec if prec > maxPrec
            maxLen = maxLen + weightFn e
        maxLen = maxLen.toString().split(".")[0].length
        (x) ->
            trieFactory.numToStr maxLen, maxPrec, x.distance
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
                marker[dst] = true
                pathEdges = []
                while queue.length > 0
                    e = queue.shift()
                    pathEdges.push e
                    e_src = edges[e].src
                    if not marker[e_src]
                        marker[e_src] = true
                        queue = queue.concat data[e_src].last
                pathEdges
            dagEdges = ->
                [].concat.apply [], (d.last for v,d of data)

            return {src,data,edgesTo,dagEdges}
    }

module.exports = dijkstra
