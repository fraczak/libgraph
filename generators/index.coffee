ld = require "lodash"
Graph = require "../"

exports.reverse = reverse = (edges=[]) ->
    (ld.assign {}, e, {src:e.dst,dst:e.src} for e in edges)

exports.circle = circle = (n = 3) ->
    ({src:"v#{i-1}",dst:"v#{i % n}"} for i in [1..n])

exports.ring = (n = 3) ->
    edges = circle n
    edges.concat reverse edges

exports.cgrid = (x=2,y) ->
    y ?= x
    edges = []
    for i in [1..x]
        for j in [1..y]
            edges.push {src:"v#{i-1}.#{j-1}", dst:"v#{i-1}.#{j % y}"}
            edges.push {src:"v#{i-1}.#{j-1}", dst:"v#{i % x}.#{j - 1}"}
    edges

exports.grid = (x=2,y) ->
    y ?= x
    edges = []
    for i in [1..x-1]
        for j in [1..y-1]
            edges.push {src:"v#{i-1}.#{j-1}", dst:"v#{i-1}.#{j % y}"}
            edges.push {src:"v#{i-1}.#{j-1}", dst:"v#{i % x}.#{j-1}"}
        edges.push {src:"v#{i-1}.#{y-1}", dst:"v#{i}.#{y-1}"}
    for j in [1..y-1]
        edges.push {src:"v#{x-1}.#{j-1}", dst:"v#{x-1}.#{j}"}
    edges

