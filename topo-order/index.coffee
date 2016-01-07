topoOrder = (graph) ->
    starts = []
    result = []
    inDegree = {}
    for v, val of graph.vertices
        degree = graph.dst[v]?.length
        if degree
            inDegree[v] = degree
        else
            starts.push v
    while x = starts.pop()
        result.push x
        outs = graph.src[x] or []
        for e in outs
            y = graph.edges[e].dst
            inDegree[y]--
            starts.push y if inDegree[y] is 0
    result

module.exports = topoOrder
