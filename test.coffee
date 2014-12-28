tests = [
    "./max-flow/test.coffee"
    "./node_modules/trie/test.coffee"
    "./minimum-cost-multi-commodity-flow/test.coffee"
    "./dfs/test.coffee"
    "./find-path/test.coffee"
    "./dijkstra/test.coffee"
    "./bellman-ford/test.coffee"
]

for test in tests
    require test
 
