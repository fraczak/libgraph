Cost = require "../Cost"
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


cost = new Cost ring, demand
cost.go (err) ->
    console.log "Problem: #{err}" if err
    console.log cost.toString()

