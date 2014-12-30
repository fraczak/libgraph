ld        = require "lodash"
Graph     = require "../Graph"
dijkstra  = require "../dijkstra"
maxFlow   = require "../max-flow"

costFn = (e) ->
    e.cost

capacityFn = (e) ->
    e.capacity

# @return the index of the first point in 'bw',
# which is "GreaterEqual" to 'point'
findNextGE = (bw, point, i=0) ->
    return -1 unless bw and bw[i]
    for k in [i..bw.length-1]
        if (point.east <= bw[k].east) and (point.west <= bw[k].west)
            return k
    return -1

# @return e.g., { east: {cost: 0, cap: 10}, west: {cost: 12, cap: 20} }
nextPoint = (bw, point, i=0) ->
    j = findNextGE bw, point, i
    return if j < 0
    res = {}
    for dir in ["east","west"]
        if (point[dir] is bw[j][dir])
            aux = ld.clone point
            aux[dir] += 1
            k = findNextGE bw, aux, j
            if k > j
                res[dir] =
                    cost: bw[k].cost - bw[j].cost
                    capacity: bw[k][dir] - point[dir]
        else
            res[dir] =
                cost: 0
                capacity: bw[j][dir] - point[dir]
    res

getNextStepCostGraph = (topo,result) ->
    new Graph ld.transform result, (res, val, i) ->
        for dir, {capacity,cost} of nextPoint val.bandwidth, val.usage
            res.push
                topoLinkIdx: i
                dir: dir
                src: if dir is "east" then topo[i].src else topo[i].dst
                dst: if dir is "east" then topo[i].dst else topo[i].src
                capacity: capacity
                cost: cost

chooseOneDemand = (demands) ->
    # return val for key, val of demands
    # heuristic: choosing a biggest one
    aux = 0
    res = undefined
    for key, d of demands
        if d.demand > aux
            res = d
            aux = d.demand
    res

minimumCost = (topo, demands, cb) ->
    result = ld.map topo, (link) ->
        bandwidth: (ld.clone link.bandwidth).sort (a,b) ->
            a.cost - b.cost
        usage:
            east: link.usage?.east or 0
            west: link.usage?.west or 0
        usagePerDemand:
            east: {}
            west: {}


    demands = ld.transform demands, (res, val, key) ->
        res[key] = ld.assign {}, val, {_id: key}
    , {}

    result.toString = ->
        s = JSON.stringify
        res =      " ====== DEMAND DISTRIBUTION ======\n"
        res +=     " == non distributed demand: #{s demands}\n"
        totalCost = 0
        for v, k in result
            u = findNextGE v.bandwidth, v.usage
            totalCost += v.bandwidth[u].cost
            continue unless v.usage.east + v.usage.west > 0
            res += "   #{k}. link #{topo[k].src} -> #{topo[k].dst}, cost: #{v.bandwidth[u].cost}\n"
            res += "      total usage  : #{s v.usage} / #{s v.bandwidth[u]} \n"
            res += "      distribution : #{s v.usagePerDemand}\n"
        res +=     " ------- Total cost: #{totalCost} -------"


    step = (demand) ->
        if demand is undefined
            return result unless cb
            return cb null, result

        graph = getNextStepCostGraph topo, result

        shortestPathEdges = dijkstra(graph, costFn)
            .from(demand.src).edgesTo(demand.dst)

        if shortestPathEdges is undefined
            throw "Failed to find a feasible solution!" unless cb
            return cb "Failed to find a feasible solution!", result

        shortestPathEdges = ld.map shortestPathEdges, (i) ->
            graph.edges[i]
        shortestPathEdges.unshift
            src: "__root__"
            dst: demand.src
            cost: 0
            capacity: demand.demand
        shortestPathGraph = new Graph shortestPathEdges

        flow = maxFlow shortestPathGraph, "__root__", demand.dst, capacityFn

        for val, i in flow.flow when val.use > 0
            graphEdge = shortestPathGraph.edges[i]
            if graphEdge.src is "__root__"
                demand.demand -= val.use
            else
                topoLink = result[graphEdge.topoLinkIdx]
                topoLink.usage[graphEdge.dir] += val.use
                topoLink.usagePerDemand[graphEdge.dir][demand._id] ?= 0
                topoLink.usagePerDemand[graphEdge.dir][demand._id] += val.use
        delete demands[demand._id] unless demand.demand > 0

        if cb
            setImmediate step, chooseOneDemand demands
        else
            step chooseOneDemand demands

    step chooseOneDemand demands

module.exports = minimumCost
