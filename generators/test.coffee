generators = require "./"

for method, fun of generators when "function" is typeof fun
    console.log "method: #{method}() ->"
    console.log fun()
