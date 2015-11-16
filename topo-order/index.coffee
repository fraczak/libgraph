ld = require "underscore"

topoOrder = (graph) ->
    starts = []
    result = []
    inDegree = ld.reduce graph.vertices, (res, val, v) ->
        if ld.isEmpty graph.dst[v]
            starts.push v
        else
            res[v] = graph.dst[v].length
        res
    , {}
    while x = starts.pop()
        result.push x
        outs = graph.src[x] or []
        for e in outs
            y = graph.edges[e].dst
            inDegree[y]--
            starts.push y if inDegree[y] is 0
    result

module.exports = topoOrder
