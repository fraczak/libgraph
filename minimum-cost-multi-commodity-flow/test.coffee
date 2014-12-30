minCost = require "./"
costData =
    demand: [
        { src: "v0", dst: "v1", demand: 20 }
        { src: "v1", dst: "v0", demand: 10 }
        { src: "v0", dst: "v2", demand: 5 }
    ]
    cost: [
        src: "v0"
        dst: "v1"
        bandwidth: [
            { east: 0, west: 0, cost:0 }
            { east: 20, west: 30, cost:100 }
            { east: 100, west: 100, cost:200 }
        ]
    ,
        src: "v1"
        dst: "v2"
        bandwidth: [
            { east: 0, west: 0, cost:0 }
            { east: 10, west: 10, cost:100 }
            { east: 100, west: 100, cost:1000 }
        ]
        usage: east: 4
    ,
        src: "v0"
        dst: "v2"
        bandwidth: [
            {east: 0, west: 0, cost:0 }
            {east: 10, west: 40, cost:100 }
            {east: 400, west: 400, cost:100 }
        ]
        usage: east: 5, west: 20
    ]

console.log (minCost costData.cost, costData.demand).toString()

# RING
bw =
    b1: [
        {east: 0, west: 0, cost: 0}
        {east:10, west:10, cost:10}
        {east:20, west:20, cost:20} ]
    b2: [
        {east: 0, west: 0, cost: 0}
        {east:10, west: 5, cost:10}
        {east:20, west:10, cost:20}
#        {east:1000, west:1000, cost:10000}
        ]
    b3: [
        {east: 0, west: 0, cost: 0}
        {east:10, west: 5, cost:100}
        {east:20, west:10, cost:200} ]

ring = [
    {src:0, dst:1, bandwidth:bw.b1}
    {src:1, dst:2, bandwidth:bw.b2}
    {src:2, dst:3, bandwidth:bw.b2}
    {src:3, dst:4, bandwidth:bw.b2}
    {src:4, dst:5, bandwidth:bw.b3}
    {src:5, dst:0, bandwidth:bw.b2}
]

demand = [
    {src:1, dst:5, demand: 3}
    {src:0, dst:4, demand: 3}
    {src:0, dst:2, demand: 3}
    {src:1, dst:3, demand: 3}

]

minCost ring, demand, (err, result) ->
    console.log "Problem: #{err}" if err
    console.log result.toString()

require "./example1.coffee"
