ld        = require "underscore"
Graph     = require "../Graph"
dijkstra  = require "../dijkstra"
maxFlow   = require "../max-flow"
MultiCommodityFlow = require "./Multi-commodity-flow"

costFn = (e) ->
    e.cost

capacityFn = (e) ->
    e.capacity

minimumCost = (topo, demands, cb) ->
    result = new MultiCommodityFlow topo, demands

    step = ->
        demand = result.chooseOneUnsatisfiedDemand()
        if demand is undefined
            for v, k in result.flows
                point = {east:v.east.total, west:v.west.total}
                v.selection = result.findGE topo[k].bandwidth, point
            return result unless cb
            return cb null, result

        graph = result.getNextStepCostGraph()

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
                usage = result.flows[graphEdge.topoIdx]
                usage[graphEdge.dir].total += val.use
                usage[graphEdge.dir].perDemand[demand._id] ?= 0
                usage[graphEdge.dir].perDemand[demand._id] += val.use

        delete result.unsatisfiedDemand_o[demand._id] unless demand.demand > 0

        if cb
            setImmediate step
        else
            step()

    step()

module.exports = minimumCost
