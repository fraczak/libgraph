dfs = (graph, root) ->
    # { visit: {v: {discoveryTime: 1, closeTime: 20, treeEdge: e}, ...},
    #   treeEdges: [...],
    #   crossEdges: [...]
    #   backEdges: [...] }
    edges = graph.edges
    res =
        visit: {}
        treeEdges: []
        crossEdges: []
        backEdges: []
    time = 1
    _run = (v,treeEdge) ->
        res.visit[v] = discoveryTime: time++, treeEdge: treeEdge
        for e in graph.src[v] or []
            y = edges[e].dst
            if res.visit[y]
                if res.visit[y].closeTime
                    res.crossEdges.push e
                else
                    res.backEdges.push e
            else
                res.treeEdges.push e
                _run y, e
        res.visit[v].closeTime = time++
    _run root
    res

module.exports = dfs
