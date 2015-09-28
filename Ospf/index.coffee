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
        #g.vertices[order[0]].input = 100
        for x in order
            v = g.vertices[x]
            continue if ld.isEmpty g.src[x]
            split = v.input.divide g.src[x].length
            #split = v.input / g.src[x].length
            for e in g.src[x]
                edges[e].traffic = split
                e_dst = g.vertices[edges[e].dst]
                e_dst.input ?= new Rat 0
                #e_dst.input ?= 0
                e_dst.input = split.add e_dst.input
                #e_dst.input = split +  e_dst.input
        return g

    utilization: (edge_indexes = [0..@graph.edges.length-1], demands = @demands) ->
        edges = ld.transform edge_indexes, (res, e) ->
            res[e] = {}
        , {}
        for {name,src,dst,traffic} in demands
            g = @distribution src, dst
            continue unless g?
            for e in g.edges when edges[e.idx]?
                edges[e.idx][name] = traffic * e.traffic
        edges

    edgeUtilization: (e_idx) ->
        res = {}
        dems = @demsOnEdge e_idx
        for src, dests of dems
            for {dst,name,traffic} in dests
                g = @distribution src, dst
                continue unless g?
                for e in g.edges when e.idx is e_idx
                    res[name] = traffic * e.traffic
        res

countDems = (dems) ->
    ld(dems)
    .map (dests) -> dests.length
    .reduce (r,n) -> r + n

Ospf:countDems = Ospf.countDems = countDems
Ospf:demandsToDems = Ospf.demandsToDems = demandsToDems

module.exports = Ospf
