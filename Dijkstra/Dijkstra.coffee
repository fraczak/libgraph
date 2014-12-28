trieFactory = require "trie"
Graph       = require "../Graph"

pad = (number, size) ->
    res = ""+number
    while (res.length < size)
        res = "0" + res
    return res if res.length is size
    throw "Number #{number} is not correctly stringified"

class Dijkstra
    constructor: (@graph, src, weightFn) ->
        edges = graph.edges
        @data = do ->
            weightFn ?= -> 1
            toStrFn = do ->
                maxLen = 0
                for e in edges
                    maxLen = maxLen + weightFn e
                maxLen = (""+maxLen).length
                (x) ->
                    pad x.len, maxLen
            res = {}
            queue = trieFactory toStrFn
            res[src] = last:[], len:0
            for i in graph.src[src] or []
                queue.add i: i, len: weightFn edges[i]
            while (queue.size() > 0)
                elem = queue.getNth 0
                queue.del elem
                {i,len} = elem
                v = edges[i].dst
                if (not res[v])
                    res[v] = last: [i], len: len
                    for ee in graph.src[v] or []
                        queue.add i: ee, len: len + weightFn edges[ee]
                else if res[v].len is len
                    res[v].last.push i
            return res

    getEdgesTo: (dst) ->
        marker = {}
        return unless @data[dst]
        queue = [].concat @data[dst].last
        pathEdges = []
        while queue.length > 0
            e = queue.shift()
            if not marker[e]
                marker[e] = true
                pathEdges.push e
                queue = queue.concat @data[@graph.edges[e].src].last
        pathEdges

    getDagTo: (dst) ->
        new Graph (@graph.edges[i] for i in @getEdgesTo dst)

module.exports = Dijkstra
