Graph = require "../"
topoOrder = require "./"

graph = new Graph [
    {src: "0", dst: "1"}
    {src: "0", dst: "2"}
    {src: "2", dst: "1"}
    {src: "5", dst: "1"}
    {src: "3", dst: "0"}
#    {src: "1", dst: "5"}
#    {src:"0",dst:"3"}
]

console.log " * Topo-order: [#{topoOrder(graph).join()}]"
