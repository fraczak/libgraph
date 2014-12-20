trieFactory = require "trie"
Graph       = require "./Graph"

pad = (number, size) ->
    res = ""+number
    while (res.length < size)
        res = "0" + res
    return res if res.length is size
    throw "Number #{number} is not correctly stringified"

class Dijkstra
    constructor: (@graph, @src, @weightFn) ->
        @data = do ->
            weightFn ?= -> 1
            toStrFn = do ->
                maxLen = 0
                for l,e of graph.edges
                    maxLen = maxLen + weightFn e
                maxLen = (""+maxLen).length
                (x) ->
                    pad x.len, maxLen
            res = {}
            queue = trieFactory toStrFn
            res[src] = last:[], len:0
            for e in graph.src[src] or []
                queue.add edge: e, len: weightFn e
            while (queue.size() > 0)
                elem = queue.getNth 0
                queue.del elem
                {edge,len} = elem
                v = edge.dst
                if (not res[v])
                    res[v] = last: [edge], len: len
                    for ee in graph.src[v] or []
                        queue.add edge: ee, len: len + weightFn ee
                else if res[v].len is len
                    res[v].last.push edge
            return res

    getEdgesTo: (dst) ->
        marker = {}
        queue = [].concat @data[dst].last
        pathEdges = []
        while queue.length > 0
            e = queue.shift()
            if not marker[e._id]
                marker[e._id] = e
                pathEdges.push e
                queue = queue.concat @data[e.src].last
            else
                console.log " * ", JSON.stringify e
                console.log "   ", JSON.stringify marker[e._id]
        pathEdges

    getDagTo: (dst) ->
        new Graph @getEdgesTo dst

module.exports = Dijkstra
