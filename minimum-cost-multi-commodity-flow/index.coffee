ld        = require "lodash"
Graph     = require "../Graph"
dijkstra  = require "../dijkstra"
maxFlow   = require "../max-flow"

LOG = (obj, indent=1) ->
    head = ("" for i in [1..indent]).join " "
    obj = JSON.stringify obj unless ld.isString obj
    console.log head + obj

LOG = ->

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

class Cost
    constructor: (@costArray, @demandArray) ->
        @cost = ld.transform @costArray, (res, val, i) ->
            res[i] =
                _id: i
                src: val.src
                dst: val.dst
                bandwidth: (ld.clone val.bandwidth).sort (a,b) ->
                    a.cost - b.cost
                usage:
                    east: val.usage?.east or 0
                    west: val.usage?.west or 0
                usagePerDemand:
                    east: {}
                    west: {}
        , {}
        @demand = ld.transform @demandArray, (res, val, key) ->
            res[key] = ld.assign {}, val, {_id: key}
        , {}
    updateWithFlow: (graph, flow, demand) ->
        # flow = {"0":{"capacity":5, "use":5}, .. }
        for key, val of flow when val.use > 0
            graphEdge = graph.edges[key]
            if graphEdge.src is "__root__"
                demand.demand -= val.use
            else
                costEdge = @cost[graphEdge.costEdgeId]
                costEdge.usage[graphEdge.dir] += val.use
                costEdge.usagePerDemand[graphEdge.dir][demand._id] ?= 0
                costEdge.usagePerDemand[graphEdge.dir][demand._id] += val.use
        delete @demand[demand._id] unless demand.demand > 0
    getNextStepCostGraph:  ->
        new Graph ld.transform @cost, (res, val, key) ->
            aux = nextPoint val.bandwidth, val.usage
            for dir, cc of aux
                res.push
                    costEdgeId: val._id
                    dir: dir
                    src: if dir is "east" then val.src else val.dst
                    dst: if dir is "east" then val.dst else val.src
                    capacity: cc.capacity
                    cost: cc.cost
        , []
    chooseOneDemand: ->
        # return val for key, val of @demand
        # heuristic: choosing a biggest one
        aux = 0
        res = null
        for key, val of @demand
            if val.demand > aux
                res = val
                aux = val.demand
        res

    # callback @done(err) will be called without args if success
    go: (done, preemptive = false) ->
        LOG " 1. Choosing a demand to process:"
        demand = @chooseOneDemand()
        return done() unless demand
        LOG demand, 2

        LOG " 2. Setting the next threshold in flows:"
        graph = @getNextStepCostGraph()
        LOG graph, 2

        LOG " 3. Calculating the shortest path graph:"
        #ddd = new Dijkstra graph, demand.src, (e) ->
        #    e.cost
        #shortestPathEdges = ddd.getEdgesTo demand.dst

        shortestPathEdges = dijkstra(graph,costFn)
            .from(demand.src).edgesTo(demand.dst)
        if shortestPathEdges is undefined
            LOG " *** Stopping: No connection found!", 2
            return done "failed to find a feasible solution"
        shortestPathEdges = ld.map shortestPathEdges, (i) ->
            graph.edges[i]
        shortestPathEdges.unshift
            src: "__root__"
            dst: demand.src
            cost: 0
            capacity: demand.demand
        shortestPathDag = new Graph shortestPathEdges
        LOG shortestPathDag, 2

        LOG " 4. Calculating the max flow:"
        flow = maxFlow shortestPathDag, "__root__", demand.dst, capacityFn
        LOG flow

        @updateWithFlow shortestPathDag, flow.flow, demand

        if preemptive
            setTimeout (=> @go done, true), 0
        else
            @go done
    toString: ->
        s = JSON.stringify
        res =      " ====== DEMAND DISTRIBUTION ======\n"
        res +=     " == non distributed demand: #{s @demand}\n"
        totalCost = 0
        for k, v of @cost
            u = findNextGE v.bandwidth, v.usage
            totalCost += v.bandwidth[u].cost
            continue unless v.usage.east + v.usage.west > 0
            res += "   #{k}. link #{v.src} -> #{v.dst}, cost: #{v.bandwidth[u].cost}\n"
            res += "      total usage  : #{s v.usage} / #{s v.bandwidth[u]} \n"
            res += "      distribution : #{s v.usagePerDemand}\n"
        res +=     " ------- Total cost: #{totalCost} -------"

module.exports = Cost
