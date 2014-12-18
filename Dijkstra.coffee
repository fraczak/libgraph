dijkstra  = require "./dijkstra"
Graph     = require "./Graph"

class Dijkstra
    constructor: (@graph, @src, @weightFn) ->
        @data = dijkstra @graph, @src, @weightFn

    getPathTo: (dst) ->
        marker = {}
        queue = [].concat @data[dst].last
        pathEdges = []
        while queue.length > 0
            e = queue.shift()
            if not marker[e._id]
                marker[e._id] = true
                pathEdges.push e 
                queue = queue.concat @data[e.src].last
            else
                console.log " * ", JSON.stringify e
        pathEdges

    getDagTo: (dst) ->
        new Graph @getPathTo dst

module.exports = Dijkstra
