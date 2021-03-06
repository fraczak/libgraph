ld           = require "underscore"
Graph        = require "../Graph"
findPath     = require "../find-path"


# returns { maxFlow: 250,
#           flow: [{use:5, capacity:10}, ...]}
maxFlow = (graph, src, dst, capacityFn) ->
    maxCapacity = 0
    flow = ld.map graph.edges, (val) ->
        capacity = capacityFn val
        maxCapacity = Math.max maxCapacity, capacity
        { capacity, use: 0 }
    return {maxFlow: Infinity, flow: flow} if src is dst

    maxFlow = 0

    edges = graph.edges

    genEdges = ->
        res = []
        for val,i in flow
            e = edges[i]
            if val.use > 0
                res.push
                    _ref: i
                    dir: ":bck"
                    capacity: val.use
                    src: e.dst, dst: e.src
            rem = val.capacity - val.use
            if rem > 0
                res.push
                    _ref: i
                    capacity: rem
                    src: e.src, dst: e.dst
                    dir: ":fwd"
        res

    aPath = null

    while (aPath = findPath (tempGraph = new Graph genEdges()), src, dst)
        tempEdges = tempGraph.edges
        useCapacity = ld.reduce aPath, (res,val) ->
            Math.min res, tempEdges[val].capacity
        , maxCapacity
        throw new Error "Capacity is ZERO!" unless useCapacity
        maxFlow += useCapacity
        for val in aPath
            e = tempEdges[val]
            if (e.dir is ':fwd')
                flow[e._ref].use += useCapacity
            else
                flow[e._ref].use -= useCapacity

    {maxFlow,flow}

module.exports = maxFlow
