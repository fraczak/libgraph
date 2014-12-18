ld = require "lodash"
class Graph
    constructor: (@edgeArray) ->
        @vertices = {}
        @edges = ld.transform @edgeArray, (res,val,i) ->
            key = ""+i
            res[key]= ld.assign {}, val, {_id: key}
        , {}
        for dir in ['src','dst']
            aux = @[dir] = {}
            for l,e of @edges
                @vertices[v = e[dir]] = {}
                aux[v] ?= []
                aux[v].push e

module.exports = Graph
