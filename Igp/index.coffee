ld        = require "underscore"
Rat       = require "rat.js"
trieFactory = require "trie-array"

Graph      = require "../"
bellmanFord = require "../bellman-ford"
dfs        = require "../dfs"
topo_order = require "../topo-order"

class RatFast
    constructor: (@val = 0) ->
    add: (x) ->
        new RatFast @val + x
    divide: (x) ->
        new RatFast @val / x
    valueOf: ->
        @val

Rat = RatFast

# {"x":{"x->y":{src:"x",dst:"y", name:"x->y", traffic:10}, ...}, ...}
demandsToDems = (demands) ->
     ld.reduce demands, (res, dem) ->
            res[dem.src][dem.name] = dem
            res
        , ld.reduce demands, (res, {src}) ->
            res[src] = {}
            res
        , {}

toStrFnGen = (edges,weightFn) ->
    maxLen = 0
    maxPrec = 0
    for e in edges
        prec = weightFn(e).toString().split(".")[1]?.length or 0
        maxPrec = prec if prec > maxPrec
        maxLen = maxLen + weightFn e
    maxLen = maxLen.toString().split(".")[0].length
    (x) ->
        trieFactory.numToStr maxLen, maxPrec, x.distance


class Igp
    # demands = [{src:"v1",dst:"v2,name:"...", traffic:"..."}, ...]
    constructor: (@graph, @demands, @weightFn = -> 1) ->
        @bf = bellmanFord @graph, @weightFn
        @vertices = Object.keys @graph.vertices
        @demands ?= @vertices.reduce (res, v) =>
            for x in @vertices when x isnt v
                 res.push {src:v,dst:x, name:"#{v}->#{x} (#{res.length})", traffic:1}
            res
        , []
        # {"x":{"x->y":{src:"x",dst:"y", name:"x->y", traffic:10}, ...}, ...}
        @dems = demandsToDems @demands
        @demandsByName = ld.indexBy @demands, "name"

        @toStrFn = toStrFnGen @graph.edges, @weightFn

    edgeIsOnShortestPath: (src,dst,e) ->
        @bf[src]?[dst]?.distance is @bf[src][e.src]?.distance + @weightFn(e) + @bf[e.dst]?[dst]?.distance

    nodeIsOnShortestPath: (src,dst,n) ->
        @bf[src][dst]?.distance is @bf[src][n]?.distance + @bf[n][dst]?.distance

    # returns {"onDemands":demands, "offDemands": demands}
    demandsOnEdge: (edge, demands = @demands) ->
        result = {"onDemands":[],"offDemands":[]}
        for d in demands
            if @edgeIsOnShortestPath d.src, d.dst, edge
                result["onDemands"].push d
            else
                result["offDemands"].push d
        result

    demandsOnEdges: (es = @graph.edges, demands = @demands) ->
        edges = [].concat(es)

        onDemands = []
        offDemands = demands

        for edge in edges
            break if ld.isEmpty offDemands
            aux = @demandsOnEdge edge, offDemands
            onDemands = onDemands.concat aux.onDemands
            offDemands = aux.offDemands

        return {onDemands, offDemands}

    utilizationOnEdges: (edge_idxs = [0..@graph.edges.length - 1]) ->
        setOfEdges = ld.indexBy edge_idxs
        demands = @demandsOnEdges ld.map edge_idxs, (idx) =>
            @graph.edges[idx]
        resultObj =
            edges: {}
            unfeasible: []
            update: (e_idx,demName,load) ->
                return unless setOfEdges[e_idx]?
                this.edges[e_idx] ?= {}
                this.edges[e_idx][demName] = load
        @utilization demands.onDemands, resultObj
        resultObj.edges

    utilization: (demands = @dems, resultObj = {
        edges: {}
        unfeasible: []
        update: (e_idx,dem_name,load) ->
            this.edges[e_idx] ?= 0
            this.edges[e_idx] += load } ) ->
        if ld.isArray demands
            dems = demandsToDems demands
        else
            dems = demands

        # {e_idx: {d1:10,d2:12}, ...}

        for src, spec of dems

            # load = {"x":{"x->y":1,"x->z":0.5, ...} }
            load = {}
            load[src] = ld.reduce spec, (res, d, name) =>
                resultObj.unfeasible.push name unless @bf[src]?[d.dst]?
                res[name] = d.traffic
                res
            , {}

            # trie of {node:"x", distance: 12.5}
            trie = trieFactory @toStrFn
            trie.add {node:src, distance: 0}

            while trie.size() > 0
                x = trie.getNth 0
                trie.del x

                # {e_idx:[d1,d2,...], ...}
                demsPerEdge = {}
                # {d1:3, ...}
                edgesPerDem = {}
                for e_idx in @graph.src[x.node] or []

                    for d_name, d_load of load[x.node]
                        if @edgeIsOnShortestPath src, @demandsByName[d_name].dst, @graph.edges[e_idx]
                            demsPerEdge[e_idx] ?= []
                            demsPerEdge[e_idx].push d_name
                            edgesPerDem[d_name] ?= 0
                            edgesPerDem[d_name] += 1

                for e_idx, e_dems of demsPerEdge
                    for d in e_dems
                        l = load[x.node][d] / edgesPerDem[d]
                        resultObj.update e_idx, d, l
                        e_dst = @graph.edges[e_idx].dst
                        if not load[e_dst]?
                            newNode = {node:e_dst,distance: @bf[src][e_dst].distance}
                            trie.add newNode
                            load[e_dst] = {}
                        load[e_dst][d] ?= 0
                        load[e_dst][d] += l

        resultObj

module.exports = Igp
