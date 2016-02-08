g = require "./index.coffee"

count = (n) ->
    n*Math.pow(2,n)/2

for n in [1,2,3,5]
    console.log "Cube d=#{n}"
    console.log JSON.stringify (c = g.cube n)
    console.log " #{c.length} ?= #{count(n)}"
