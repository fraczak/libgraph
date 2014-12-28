ld = require "lodash"
class Graph
    constructor: (@edges,@vertices={}) ->
        for dir in ['src','dst']
            aux = @[dir] = {}
            for e,i in @edges
                @vertices[v = e[dir]] ?= '__discovered__'
                aux[v] ?= []
                aux[v].push i

module.exports = Graph
