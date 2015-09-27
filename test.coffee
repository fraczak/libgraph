tests = [
    "./max-flow/test.coffee"
    "./minimum-cost-multi-commodity-flow/test.coffee"
    "./dfs/test.coffee"
    "./find-path/test.coffee"
    "./dijkstra/test.coffee"
    "./bellman-ford/test.coffee"
    "./topo-order/test.coffee"
    "./generators/test.coffee"
    "./Ospf/test.coffee"
]

for test in tests
    require test
 
