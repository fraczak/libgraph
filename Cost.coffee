ld        = require "lodash"
Graph     = require "./Graph"
Dijkstra  = require "./Dijkstra"
maxFlow   = require "./max-flow"


findNextGE = (bw, point, i=0) ->
    return -1 unless bw and bw[i]
    for k in [i..bw.length-1]
        if (point.east <= bw[k].east) and (point.west <= bw[k].west)
            return k
    return -1

# returns, e.g., { east: {cost: 0, cap: 10}, west: {cost: 12, cap: 20} }
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
    updateWithFlow: (flow, demand) ->
        # flow = {"0":{"_ref":graph_edge, "capacity":5, "use":5}, .. }
        for key, val of flow when val.use > 0
            graphEdge = val._ref
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
#        console.log "DEMAND:", JSON.stringify @demand, "", 2
#        console.log "COST  :", JSON.stringify @cost, "", 2
        for key, val of @demand
            return val

    go: (done) ->
        demand = @chooseOneDemand()
        return done() unless demand
#        console.log " #1 Choose a demand:", JSON.stringify demand
        graph = @getNextStepCostGraph()
#        console.log " #2 Next level cost graph: ", JSON.stringify graph
        ddd = new Dijkstra graph, demand.src, (e) ->
            e.cost
        shortestPathEdges = ddd.getEdgesTo demand.dst
        shortestPathEdges.unshift
            src: "__root__"
            dst: demand.src
            cost: 0
            capacity: demand.demand
        shortestPathDag = new Graph shortestPathEdges
#        console.log " #3 Shortest path graph:", JSON.stringify shortestPathDag
        flow = maxFlow shortestPathDag, "__root__", demand.dst, (e) ->
            e.capacity
#        console.log " #4 Max Flow:", JSON.stringify flow
        @updateWithFlow flow.flow, demand
        setTimeout (=> @go done), 0

    print: ->
        totalCost = 0
        for k, v of @cost
            u = findNextGE v.bandwidth, v.usage
            totalCost += v.bandwidth[u].cost
            console.log "#{k}[#{v.src} -> #{v.dst}], Cost: #{v.bandwidth[u].cost}, Usage: #{JSON.stringify v.usage}, step: [#{JSON.stringify v.bandwidth[u]}]"
            console.log "   #{JSON.stringify v.usagePerDemand}"
        console.log "Total cost: #{totalCost}"
module.exports = Cost
