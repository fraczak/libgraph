ld        = require "lodash"
Graph     = require "../Graph"


# @bw - bandwidth array (sorted by preference (i.e., cost)
#       `[ { east: 10, west: 20, cost:0 }, { east: 20, west: 30, cost:100 } ]`
# @point - e.g., `{east: 7, west: 30}`
# @i - start index in `bw`
# Find the index of the first point in 'bw' "GreaterEqual" to `point`
# @return - the index or -1 if not such point found
findGE = (bw, point, i=0) ->
    return -1 unless bw and bw[i]
    for k in [i..bw.length-1]
        if (point.east <= bw[k].east) and (point.west <= bw[k].west)
            return k
    return -1

# @bw - bandwidth array (sorted by preference (i.e., cost)
#       `[{ east:10, west:20, cost:10 }, { east:20, west:30, cost:100 }]`
# @point - e.g., `{east: 7, west: 20}`
# @i - start index in `bw`
# Calculate the "next traffic point" (and its cost) able to carry
# non-empty traffic (in both directions)
# @return - e.g. `{east:{cost:0, capacity:3}, west:{cost:90, capacity:10}}`
#    or `undefined`
nextPoint = (bw, point, i=0) ->
    j = findGE bw, point, i
    return {} if j < 0
    res = {}
    for dir in ["east","west"]
        if (point[dir] is bw[j][dir])
            aux = ld.clone point
            aux[dir] += 1
            k = findGE bw, aux, j
            if k > j
                res[dir] =
                    cost: bw[k].cost - bw[j].cost
                    capacity: bw[k][dir] - point[dir]
        else
            res[dir] =
                cost: 0
                capacity: bw[j][dir] - point[dir]
    res


# @topo - `[
#     src: "v0"
#     dst: "v1"
#     bandwidth: [
#         { east: 0, west: 0, cost:0 }
#         { east: 20, west: 30, cost:100 }
#         { east: 100, west: 100, cost:200 } ]
# ,
#     src: "v1"
#     dst: "v2"
#     bandwidth: [
#         { east: 0, west: 0, cost:0 }
#         { east: 10, west: 10, cost:100 }
#         { east: 100, west: 100, cost:1000 } ]
#     usage: east: 4
# ,
#     src: "v0"
#     dst: "v2"
#     bandwidth: [
#         {east: 0, west: 0, cost:0 }
#         {east: 10, west: 40, cost:100 }
#         {east: 400, west: 400, cost:100 } ]
#     usage: east: 5, west: 20 ]`
# @demand - `[
#     { src: "v0", dst: "v1", demand: 20 }
#     { src: "v1", dst: "v0", demand: 10 }
#     { src: "v0", dst: "v2", demand: 5 } ]`

class MultiCommodityFlow
    findGE: findGE
    constructor: (@topo=[], @demand=[]) ->
        @flows = ( {
            east:
                total: link.usage?.east or 0
                perDemand: {}
            west:
                total: link.usage?.west or 0
                perDemand: {}
            } for link in @topo )
        @unsatisfiedDemand_o = ld.transform @demand, (res, val, key) ->
            res[key] = ld.assign {}, val, {_id: key}
        , {}
        # in case the bandwidth points are not sorted, do:
        for link in @topo
            link.bandwidth.sort (x,y) ->
                x.cost - y.cost

    chooseOneUnsatisfiedDemand: ->
        # return val for key, val of @unsatisfiedDemand_o
        # heuristic: choosing a biggest one
        aux = 0
        res = undefined
        for key, d of @unsatisfiedDemand_o
            if d.demand > aux
                res = d
                aux = d.demand
        res

    getNextStepCostGraph: ->
        new Graph ld.transform @flows, (res, val, i) =>
            point = nextPoint @topo[i].bandwidth,
                east: val.east.total
                west: val.west.total
            for dir, {capacity,cost} of point
                res.push
                    topoIdx: i
                    dir: dir
                    src: if dir is "east" then @topo[i].src else @topo[i].dst
                    dst: if dir is "east" then @topo[i].dst else @topo[i].src
                    capacity: capacity
                    cost: cost

    toString: ->
        s = JSON.stringify
        res =      " ====== DEMAND DISTRIBUTION ======\n"
        res +=     " == non distributed demand: #{s @unsatisfiedDemand_o}\n"
        totalCost = 0
        for v, k in @flows
            bw = @topo[k].bandwidth
            point =  { east: v.east.total, west: v.west.total }
            u = findGE bw, point
            cost = bw[u].cost
            totalCost += cost
            continue unless v.east.total + v.west.total + cost > 0
            # don't show when nothing to show
            res += "   #{k}. link #{@topo[k].src} -> #{@topo[k].dst}, cost: #{cost}\n"
            res += "      total usage  : #{s point} / #{s bw[u]} \n"
            res += "      details : #{s v}\n"
        res +=     " ------- Total cost: #{totalCost} -------"

    # @demand_idx - a demand
    # @return [ {link:idx, east: 10, west: 0}, ...]
    usage: (demand_idx) ->
        MultiCommodityFlow.usage this, demand_idx

    usageGraph: (demand_idx) ->
        MultiCommodityFlow.usageGraph this, demand_idx

MultiCommodityFlow.cast = (obj) ->
    newObj = Object.create MultiCommodityFlow.prototype
    ld.assign newObj, obj

MultiCommodityFlow.usage = (commodityFlow, demand_idx) ->
    flows = commodityFlow.flows
    ({
        link: idx
        east: flow.east.perDemand?[demand_idx] ? 0
        west: flow.west.perDemand?[demand_idx] ? 0
        } for flow, idx in flows )

MultiCommodityFlow.usageGraph = (commodityFlow, demand_idx) ->
    usage = MultiCommodityFlow.usage commodityFlow, demand_idx
    topo = commodityFlow.topo
    edges = ( topo[u.link] for u in usage when 0 < u.east + u.west )
    graph = new Graph edges

module.exports = MultiCommodityFlow
