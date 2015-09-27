ld = require "lodash"

Graph = require "../"
dijkstra = require "../dijkstra"
dfs      = require "../dfs"

class Ospf
    # demands = [{src:"v1",dst:"v2,name:"...", traffic:"..."}, ...]
    constructor: (@graph, @demands, weightFn = -> 1) ->
        @dijkstra = dijkstra @graph, weightFn
        @vertices = Object.keys @graph.vertices
        @demands ?= ld.transform @vertices, (res, v) =>
            for x in @vertices when x isnt v
                 res.push {src:v,dst:x}
        @dems = ld.transform @demands, (res, d, i) ->
            {src,dst,name,traffic} = d
            name ?= "#{src}->#{dst} (#{i})"
            traffic ?= 1
            res[src] ?= []
            res[src].push {name,dst,traffic}
        , {}

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

module.exports = Ospf
