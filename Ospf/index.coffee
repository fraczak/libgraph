ld        = require "lodash"
Rat       = require "rat.js"

Graph      = require "../"
dijkstra   = require "../dijkstra"
dfs        = require "../dfs"
topo_order = require "../topo-order"

demandsToDems = (demands) ->
    ld.transform demands, (res, d, i) ->
        {src,dst,name,traffic} = d
        name ?= "#{src}->#{dst} (#{i})"
        traffic ?= 1
        res[src] ?= []
        res[src].push {name,dst,traffic}
    , {}

class Ospf
    # demands = [{src:"v1",dst:"v2,name:"...", traffic:"..."}, ...]
    constructor: (@graph, @demands, weightFn = -> 1) ->
        @dijkstra = dijkstra @graph, weightFn
        @vertices = Object.keys @graph.vertices
        @demands ?= ld.transform @vertices, (res, v) =>
            for x in @vertices when x isnt v
                 res.push {src:v,dst:x, name:"#{v}->#{x}", traffic:1}
        @dems = demandsToDems @demands

    demsOnEdge: (e) ->
        edges =  @graph.edges
        result = {}
        e_dst = edges[e].dst
        for src, dests of @dems
            dagEdges = @dijkstra.from(src).dagEdges()
            continue unless 0 <= dagEdges.indexOf(e)
            dag = new Graph ld.map dagEdges, (idx) ->
                edges[idx]
            fromDest = dfs dag, e_dst
            reachableDests = ld.filter dests, (v) ->
                fromDest.visit[v.dst]?
            continue if ld.isEmpty reachableDests
            result[src] = reachableDests
        return result

    distribution: (src,dst) ->
        edgeIdxes = @dijkstra.from(src).edgesTo(dst)
        return if ld.isEmpty edgeIdxes
        edges = ld.map edgeIdxes, (idx) =>
            ld.assign {idx, traffic: undefined}, @graph.edges[idx]
        g = new Graph edges
        order = topo_order g
        g.vertices[order[0]].input = new Rat 1
        for x in order
            v = g.vertices[x]
            continue if ld.isEmpty g.src[x]
            split = v.input.divide g.src[x].length
            for e in g.src[x]
                edges[e].traffic = split
                e_dst = g.vertices[edges[e].dst]
                e_dst.input ?= new Rat 0
                e_dst.input = split.add e_dst.input
        return g

    utilization: (edge_indexes = [0..@graph.edges.length-1], demands = @demands) ->
        updateFn =  (result, index, demand_name, traffic) ->
            if result[index]?
                result[index][demand_name] = traffic
        return @_utilization {}, updateFn, edge_indexes, demands

    totalUtilization: (edge_indexes = [0..@graph.edges.length-1], demands = @demands) ->
        updateFn = (result, index, demand_name, value) ->
            if result[index]?
                result[index] += value
        @_utilization 0, updateFn, edge_indexes, demands

    _utilization: (initValue, updateFn, edge_indexes, dems) ->
        edges = ld.transform edge_indexes, (res, e) ->
            res[e] = initValue
        , {}
        dems = demandsToDems dems if ld.isArray dems
        for src, dests of dems
            dijkstra_from = @dijkstra.from src
            dagEdges = dijkstra_from.dagEdges()
            continue if ld dagEdges
                .filter (x) -> edges[x]?
                .isEmpty()
            for {dst,name,traffic} in dests
                shortestPathEdges = dijkstra_from.edgesTo dst
                continue if ld.isEmpty shortestPathEdges
                dag = new Graph ld.map shortestPathEdges, (idx) =>
                    ld.assign {}, @graph.edges[idx], {idx}
                order = topo_order dag
                dag.vertices[order[0]].input = new Rat 1
                for x in order
                    v = dag.vertices[x]
                    continue if ld.isEmpty dag.src[x]
                    split = v.input.divide dag.src[x].length
                    for e in dag.src[x]
                        updateFn edges, dag.edges[e].idx, name, split * traffic
                        e_dst = dag.vertices[dag.edges[e].dst]
                        e_dst.input ?= new Rat 0
                        e_dst.input = split.add e_dst.input
        edges

countDems = (dems) ->
    ld(dems)
    .map (dests) -> dests.length
    .reduce (r,n) -> r + n

Ospf::countDems = Ospf.countDems = countDems
Ospf::demandsToDems = Ospf.demandsToDems = demandsToDems

module.exports = Ospf


