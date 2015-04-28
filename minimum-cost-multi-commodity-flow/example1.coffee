ajson = require "dag-json"
exampleData = require "./example1.json"
minCost = require "../minimum-cost-multi-commodity-flow"

exampleData = ajson.unalias exampleData

minCost exampleData.topo, exampleData.demand, (err, result) ->
    if err
        console.log err
    else
        console.log result.toString()

