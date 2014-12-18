ld = require "lodash"
Graph = require "./Graph"
nextPoint = require "./next-point"
Dijkstra = require "./Dijkstra"
maxFlow = require "./max-flow"
# Demand
demandExample = [
    src: "v0", dst: "v1", demand: 20
,
    src: "v1", dst: "v0", demand: 10
,
    src: "v0", dst: "v2", demand: 5
]

costExample = [
    src: "v0"
    dst: "v1"
    bandwidth: [
        east: 0, west: 0, cost:0
    ,
        east: 20, west: 30, cost:100
    ,
        east: 100, west: 100, cost:200
    ]
,
    src: "v1"
    dst: "v2"
    bandwidth: [
        east: 0, west: 0, cost:0
    ,
        east: 10, west: 10, cost:100
    ,
        east: 100, west: 100, cost:1000
    ]
    usage: east: 4
,
    src: "v0"
    dst: "v2"
    bandwidth: [
        east: 0, west: 0, cost:0
    ,
        east: 10, west: 40, cost:100
    ,
        east: 400, west: 400, cost:100
    ]
    usage: east: 5, west: 20
]

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
    updateWithFlow: (flow,demand) ->
        # flow = {"0":{"_ref":*to_graph_edge, "capacity":5,"use":5}, .. }
        for key, val of flow when val.use > 0
            graphEdge = val._ref
            if graphEdge.src is "__root__"
                demand.demand -= val.use
            else
                costEdge = graphEdge._ref
                costEdge.usage[graphEdge._dir] += val.use
                costEdge.usagePerDemand[graphEdge._dir][demand._id] ?= 0
                costEdge.usagePerDemand[graphEdge._dir][demand._id] += val.use
        delete @demand[demand._id] unless demand.demand > 0
    getNextStepCostGraph:  ->
        # usage {costEdge_id -> [est, west]}
        new Graph ld.transform @cost, (res, val, key) ->
            aux = nextPoint val.bandwidth, val.usage
            for dir, cc of aux
                res.push
                    _ref: val
                    _dir: dir
                    src: if dir is "east" then val.src else val.dst
                    dst: if dir is "east" then val.dst else val.src
                    capacity: cc.capacity
                    cost: cc.cost
        , []
    chooseOneDemand: ->
        console.log "DEMAND:", JSON.stringify @demand, "", 2
        console.log "COST  :", JSON.stringify @cost, "", 2
        for key, val of @demand
            return val

    go: (done) ->
        demand = @chooseOneDemand()
        return done() unless demand
#        console.log ".... 1", JSON.stringify demand
        graph = @getNextStepCostGraph()
#        console.log ".... 2", JSON.stringify graph
        ddd = new Dijkstra graph, demand.src, (e) ->
            e.cost
#        console.log ".... 3", JSON.stringify ddd
        shortestPath = ddd.getPathTo demand.dst
#        console.log ".... 4", JSON.stringify shortestPath
        shortestPath.unshift
            _ref: null # artificial "demand throttle" edge
            _dir: "east"
            src: "__root__"
            dst: demand.src
            cost: 0
            capacity: demand.demand
        shortestPathDag = new Graph shortestPath
#        console.log ".... 5", JSON.stringify shortestPathDag
        flow = maxFlow shortestPathDag, "__root__", demand.dst, (e) ->
            e.capacity
#        console.log ".... 6", JSON.stringify flow
#        console.log flow
        @updateWithFlow flow.flow, demand
        setTimeout =>
            console.log ".... calling"
            @go done
        , 0

Cost.e =
    demand: demandExample
    cost: costExample

module.exports = Cost
