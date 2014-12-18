ld = require "lodash"

#bw = [
#    { east: 10, west: 0, cost: 10 }
#    { east: 10, west: 20, cost: 20 }
#    { east: 20, west: 20, cost: 30 }
#    { east: 25, west: 30, cost: 40 }
#]

findNextBE = (bw, point, i=0) ->
    return -1 unless bw and bw[i]
    for k in [i..bw.length-1]
        if (point.east <= bw[k].east) and (point.west <= bw[k].west)
            return k
    return -1

# returns, e.g., { east: {cost: 0, cap: 10}, west: {cost: 12, cap: 20} }
nextPoint = (bw, point, i=0) ->
    j = findNextBE bw, point, i
    return if j < 0
    res = {}
    for dir in ["east","west"]
        if (point[dir] is bw[j][dir])
            aux = ld.clone point
            aux[dir] += 1
            k = findNextBE bw, aux, j
            if k > j
                res[dir] =
                    cost: bw[k].cost - bw[j].cost
                    capacity: bw[k][dir] - point[dir]
                console.log " /////////////////", res[dir]
        else
            res[dir] =
                cost: 0
                capacity: bw[j][dir] - point[dir]
    res

module.exports = nextPoint
