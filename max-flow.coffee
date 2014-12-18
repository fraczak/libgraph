ld           = require "lodash"
Graph        = require "./Graph"
findPath     = require "./find-path"


# returns { maxFlow: 250,
#           flow: {e1: {_ref: *to_graph_edge, use:5, capacity:10}, ...}}
maxFlow = (graph, src, dst, capacityFn) ->
    flow = ld.transform graph.edges, (res,val,key) ->
        res[key] =
            _ref: val
            capacity: capacityFn val
            use: 0
    , {}
    return {maxFlow: Infinity, flow: flow} if src is dst

    maxFlow = 0

    genEdges = ->
        res = []
        for key,val of flow
            e = graph.edges[key]
            if val.use > 0
                res.push
                    _ref: val
                    capacity: val.use
                    src: e.dst, dst: e.src
                    dir: ":bck"
            rem = val.capacity - val.use
            if rem > 0
                res.push
                    _ref: val
                    capacity: rem
                    src: e.src, dst: e.dst
                    dir: ":fwd"
        res

    aPath = null

    while (aPath = findPath (new Graph genEdges()), src, dst)
        useCapacity = ld.reduce aPath, (res,val) ->
            Math.min res, val.capacity
        , aPath[0].capacity
        throw new Error "Capacity is ZERO!" unless useCapacity
        maxFlow += useCapacity
        for val in aPath
            if (val.dir is ':fwd')
                val._ref.use += useCapacity
            else
                val._ref.use -= useCapacity

    {maxFlow,flow}

module.exports = maxFlow
