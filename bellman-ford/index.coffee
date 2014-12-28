# res =
#     v0:
#         v0: way: [], distance: 0
#         v1: way: [e1,e2], distance: 20
#         ...
#     v1: ...
bellmanFord = (graph, weightFn) ->
    weightFn ?= -> 1
    res = {}
    nbV = 0
    edges = graph.edges
    for x,v of graph.vertices
        nbV++
        res[x] = {}
        res[x][x] = {way:[], distance:0}
    for i in [1..nbV]
        lastRound = true
        for x,v of graph.vertices
            for e in (graph.src[x] or [])
                edge = edges[e]
                y = edge.dst
                w = weightFn edge
                for z,v of res[y]
                    if (not res[x][z]) or (res[x][z].distance > w + res[y][z].distance)
                        lastRound = false
                        res[x][z] = {way: [e], distance: w + res[y][z].distance}
                    else if (res[x][z].distance is w + res[y][z].distance) and (-1 is res[x][z].way.indexOf e)
                        lastRound = false
                        res[x][z].way.push e
        return res if lastRound
    throw "Graph with negative cycles"

module.exports = bellmanFord
