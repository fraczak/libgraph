# res =
#     v0:
#         v0: way: [], len: 0
#         v1: way: [e1,e2], len: 20
#         ...
#     v1: ...
bellmanFord = (graph, weightFn) ->
    weightFn ?= -> 1
    res = {}
    nbV = 0
    for x,v of graph.vertices
        nbV++
        res[x] = {}
        res[x][x] = {way:[], len:0}
    for i in [1..nbV]
        lastRound = true
        for x,v of graph.vertices
            for e in (graph.src[x] or [])
                y = e.dst
                w = weightFn e
                for z,v of res[y]
                    if (not res[x][z]) or (res[x][z].len > w + res[y][z].len)
                        lastRound = false
                        res[x][z] = {way: [e], len: w + res[y][z].len}
                    else if (res[x][z].len is w + res[y][z].len) and (-1 is res[x][z].way.indexOf e)
                        lastRound = false
                        res[x][z].way.push e
        return res if lastRound
    throw "Graph with negative cycles"

module.exports = bellmanFord
