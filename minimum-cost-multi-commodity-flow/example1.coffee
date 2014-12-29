ajson = require "ajson"
exampleData = require "./example1.json"
Cost = require "../minimum-cost-multi-commodity-flow"

exampleData = ajson.unalias exampleData

cost = new Cost exampleData.topo, exampleData.demand

cost.go (err) ->
    if err
        console.log err
    else
        console.log cost.toString()
        
