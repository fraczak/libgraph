ld = require "underscore"

exports.reverse = reverse = (edges=[]) ->
    (ld.assign {}, e, {src:e.dst,dst:e.src} for e in edges)

exports.circle = circle = (n = 3) ->
    ({src:"v#{i-1}",dst:"v#{i % n}"} for i in [1..n])

exports.ring = (n = 3) ->
    edges = circle n
    edges.concat reverse edges

exports.star = star = (n = 3) ->
    ({src:"v#{n}",dst:"v#{i-1}"} for i in [1..n])

exports.bstar = (n = 3) ->
    edges = star n
    edges.concat reverse edges

exports.wheel = wheel = (n=3) ->
    star n
    .concat circle n

exports.click = (n = 3) ->
    edges = []
    for i in [1..n-1]
        edges = edges.concat ({src:"v#{i}",dst:"v#{j}"} for j in [i-1..0])
    edges.concat reverse edges

exports.cube = cube = (d=3) ->
    matrix = ("0" for x in [1..d]).join ""
    vertices = [""]
    edges=[]
    for i in [1..d]
        suffix = matrix.substring i
        newVertices = []
        for v in vertices
            v0 = v+"0"
            v1 = v+"1"
            edges.push {
                src:"v#{parseInt(v0+suffix,2)}"
                dst:"v#{parseInt(v1+suffix,2)}"
            }
            newVertices.push v0
            newVertices.push v1
        vertices = newVertices
    edges

exports.bwheel = (n=3) ->
    edges = wheel n
    edges.concat reverse edges

exports.cgrid = (x=2,y) ->
    y ?= x
    edges = []
    for i in [1..x]
        for j in [1..y]
            edges.push {src:"v#{i-1}x#{j-1}", dst:"v#{i-1}x#{j % y}"}
            edges.push {src:"v#{i-1}x#{j-1}", dst:"v#{i % x}x#{j - 1}"}
    edges

exports.grid = grid = (x=2,y) ->
    y ?= x
    edges = []
    for i in [1..x-1]
        for j in [1..y-1]
            edges.push {src:"v#{i-1}x#{j-1}", dst:"v#{i-1}x#{j % y}"}
            edges.push {src:"v#{i-1}x#{j-1}", dst:"v#{i % x}x#{j-1}"}
        edges.push {src:"v#{i-1}x#{y-1}", dst:"v#{i}x#{y-1}"}
    for j in [1..y-1]
        edges.push {src:"v#{x-1}x#{j-1}", dst:"v#{x-1}x#{j}"}
    edges

exports.lattice = (x,y) ->
    edges = grid x, y
    edges.concat reverse edges

