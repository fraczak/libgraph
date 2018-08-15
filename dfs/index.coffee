dfs = (graph, root) ->
    # { visit: {v: {discoveryTime: 1, closeTime: 20, treeEdge: e, depth: 1}, ...},
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
    _run = (v,depth,treeEdge) ->
        res.visit[v] = discoveryTime: time++, treeEdge: treeEdge, depth: depth
        for e in graph.src[v] or []
            y = edges[e].dst
            if res.visit[y]
                if res.visit[y].closeTime
                    res.crossEdges.push e
                else
                    res.backEdges.push e
            else
                res.treeEdges.push e
                _run y, (depth + 1), e
        res.visit[v].closeTime = time++
    _run root, 0
    res

module.exports = dfs
