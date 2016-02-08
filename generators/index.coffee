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

exports.bin_cube = bin_cube = (d=3) ->
    return [{src:"0", dst:"1"}] unless d > 1
    sub_cube = bin_cube d - 1
    vertices = {}
    for {src,dst} in sub_cube
        vertices[src] = true
        vertices[dst] = true
    [].concat ( [
            {src:src+"0",dst:dst+"0"}
            {src:src+"1",dst:dst+"1"}
        ] for {src,dst} in sub_cube )...,
        ({src:x+"0",dst:x+"1"} for x of vertices)

exports.cube = cube = (d=3) ->
    for {src,dst} in bin_cube d
        src: "v#{parseInt(src,2)}"
        dst: "v#{parseInt(dst,2)}"

exports.bcube = (d=3) ->
    edges = cube d
    edges.concat reverse edges

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

