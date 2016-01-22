ld         = require "underscore"
KeepNFirst = require "keep-n-first"
Ospf       = require "./index.coffee"
Graph      = require "../Graph.coffee"

_composeUtilization = (fn) -> (u1,u2) ->
    ld.reduce u1, (res, val, idx) ->
        if u2[idx]?
            res[idx] = fn val, u2[idx]
        else
            res[idx] = val
        res
    , {}

addUtilization = _composeUtilization (x,y) -> x + y
subUtilization = _composeUtilization (x,y) -> x - y

compMaxUtilFn = (u1, u2) ->
    res = Ospf.countDems(u1.unfeasibleDems) - Ospf.countDems(u2.unfeasibleDems)
    if res is 0
        return ld.max(u1.edges) - ld.max(u2.edges)
    res

failureUtilization = (ospf, utilization, downEdges) ->
    demsOnDownEdges = ospf.demsOnEdges downEdges

    return utilization if ld.isEmpty demsOnDownEdges

    graph = ospf.graph
    edges = graph.edges
    weightFn = ospf.weightFn
    stopWeight = edges.reduce (r,x) ->
        r + weightFn(x)
    , 0
    downEdgesIdx = ld.indexBy downEdges
    downEdgesMap = downEdges.reduce (res,e_idx) ->
        res[JSON.stringify edges[e_idx]] = true
        res
    , {}

    baseUtilizationEdges = subUtilization utilization.edges, ospf.totalUtilization(null, demsOnDownEdges).edges
    #console.log {downEdges}
    #console.log JSON.stringify baseUtilizationEdges, "", 2

    tempGraph = new Graph edges.reduce (res, e, _idx) ->
        res.push ld.assign {}, e, {_idx} unless downEdgesIdx[_idx]?
        res
    , []

    reroutedOspf = new Ospf tempGraph, Ospf.demsToDemands(demsOnDownEdges), weightFn

    reroutedUtilization = reroutedOspf.totalUtilization()

    #console.log JSON.stringify {reroutedUtilization}, "", 2

    tempEdges = tempGraph.edges
    uu = ld.reduce reroutedUtilization.edges, (res, u, e) ->
        res[tempEdges[e]._idx] = u
        res
    , {}
    #console.log JSON.stringify {uu}, "", 2

    onEdges = addUtilization baseUtilizationEdges, uu
    #console.log JSON.stringify {onEdges}, "", 2

    edges: onEdges
    unfeasibleDems: reroutedUtilization.unfeasibleDems

wcf = (ospf, failureList, keep, compUtilFn = compMaxUtilFn) ->
    graph = ospf.graph
    edges = graph.edges

    #failureList ?= ( [].concat graph.src[v], graph.dst[v] for v of graph.vertices )
    failureList ?= ( [i] for i in [0..edges.length - 1] )
    failureList.push []
    keep ?= edges.length # keep all
    utilization = ospf.totalUtilization()
    #console.warn "unfeasibleDems: #{JSON.sytingify utilization.unfeasibleDems}" unless ld.isEmpty utilization.unfeasibleDems

    res = new KeepNFirst keep, (x,y) ->
        # x, y are of form {failureSet, utilization}
        compUtilFn y.utilization, x.utilization

    for failureSet in failureList
        res.add {failureSet, utilization: failureUtilization ospf, utilization, failureSet}

    res.values

module.exports = wcf
