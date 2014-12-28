Graph    = require "../Graph"
findPath = require "./"
testGraphEdges =  require("./graph.json")

console.log g = new Graph testGraphEdges, {s: "with no edges"}

console.log "Path from '0' to '3':", findPath g, '0', '3'
console.log "Path from '2' to '2':", findPath g, '2', '2'
console.log "Path from '4' to 's':", findPath g, '4', 's'

console.log g2 = new Graph [
    { _ref: '0', capacity: 5, src: 0, dst: 1, dir: ':fwd' },
    { _ref: '1', capacity: 10, src: 0, dst: 1, dir: ':fwd' },
    { _ref: '2', capacity: 10, src: 1, dst: 2, dir: ':fwd' },
    { _ref: '3', capacity: 10, src: 2, dst: 3, dir: ':fwd' },
    { _ref: '4', capacity: 12, src: 3, dst: 0, dir: ':fwd' },
    { _ref: '5', capacity: 6, src: 0, dst: 3, dir: ':fwd' },
    { _ref: '6', capacity: 6, src: 3, dst: 2, dir: ':fwd' },
    { _ref: '7', capacity: 6, src: 2, dst: 1, dir: ':fwd' },
    { _ref: '8', capacity: 6, src: 1, dst: 0, dir: ':fwd' },
    { _ref: '9', capacity: 4, src: 0, dst: 2, dir: ':fwd' } ]

console.log "Path from '0' to '1':", findPath g2, '0', '1'

