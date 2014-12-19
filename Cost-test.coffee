exports.demand = [
    src: "v0", dst: "v1", demand: 20
,
    src: "v1", dst: "v0", demand: 10
,
    src: "v0", dst: "v2", demand: 5
]

exports.cost = [
    src: "v0"
    dst: "v1"
    bandwidth: [
        east: 0, west: 0, cost:0
    ,
        east: 20, west: 30, cost:100
    ,
        east: 100, west: 100, cost:200
    ]
,
    src: "v1"
    dst: "v2"
    bandwidth: [
        east: 0, west: 0, cost:0
    ,
        east: 10, west: 10, cost:100
    ,
        east: 100, west: 100, cost:1000
    ]
    usage: east: 4
,
    src: "v0"
    dst: "v2"
    bandwidth: [
        east: 0, west: 0, cost:0
    ,
        east: 10, west: 40, cost:100
    ,
        east: 400, west: 400, cost:100
    ]
    usage: east: 5, west: 20
]
