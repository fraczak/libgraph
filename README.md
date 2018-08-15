# libgraph

`javascript` libs for graphs.

    npm i libgraph

## `libgraph/Graph` -- data-structure

`Graph` class is defined in `./Graph.coffee`.
By `graph` we mean a directed graph with multi-edges and loops. 
A `graph` consists of:

 - `edges` : a list (vector) of "edges";
 - `vertices` : a map from vertex name to its payload;
 - `src` : a map from the vertex name to the list of indexed (position
   in the list of `edges`) of outgoing edges of the vertex;
 - `dst` : a map from the vertex name to the list of indexed (position
   in the list of `edges`) of incoming edges to the vertex;

For example:

    Graph {
      edges: [ 
        { src: 'a', dst: 'b', weigth: 12 }, 
        { src: 'b', dst: 'b' } ],
      vertices: { 
        a: { label: 'a' }, 
        b: { _rem: 'discovered' } },
      src: { a: [ 0 ], b: [ 1 ] },
      dst: { b: [ 0, 1 ] } }

The above graph can be constructed by:

    var Graph = require("libgraph/Graph");
    var my_graph = new Graph([{src: 'a', dst: 'b'}, {src: 'b', dst: 'b'}], {a: {label: "a"}});

The data structure allows us to store any meta-data in a vertex and an
edge.  Properties `src` and `dst` are used for navigation within the
graph from a vertex to its neighbors.

## `libgraph/generators` -- helper functions to build graphs

Some helper functions for building graphs are provided there.

For example:

    var Graph = require("libgraph/Graph"),
        gener = require("libgraph/generators");
    var cycle = new Graph(gener.cycle(5)),
        grid  = new Graph(gener.grid(2,2));
    

`cycle` will be:

    Graph {
      edges: 
       [ { src: 'v0', dst: 'v1' },
         { src: 'v1', dst: 'v2' },
         { src: 'v2', dst: 'v3' },
         { src: 'v3', dst: 'v4' },
         { src: 'v4', dst: 'v0' } ],
      vertices: 
       { v0: { _rem: 'discovered' },
         v1: { _rem: 'discovered' },
         v2: { _rem: 'discovered' },
         v3: { _rem: 'discovered' },
         v4: { _rem: 'discovered' } },
      src: { v0: [ 0 ], v1: [ 1 ], v2: [ 2 ], v3: [ 3 ], v4: [ 4 ] },
      dst: { v1: [ 0 ], v2: [ 1 ], v3: [ 2 ], v4: [ 3 ], v0: [ 4 ] } }

and `grid` will be:

    Graph {
      edges: 
       [ { src: 'v0x0', dst: 'v0x1' },
         { src: 'v0x0', dst: 'v1x0' },
         { src: 'v0x1', dst: 'v1x1' },
         { src: 'v1x0', dst: 'v1x1' } ],
      vertices: 
       { v0x0: { _rem: 'discovered' },
         v0x1: { _rem: 'discovered' },
         v1x0: { _rem: 'discovered' },
         v1x1: { _rem: 'discovered' } },
      src: { v0x0: [ 0, 1 ], v0x1: [ 2 ], v1x0: [ 3 ] },
      dst: { v0x1: [ 0 ], v1x0: [ 1 ], v1x1: [ 2, 3 ] } }


## `libgraph/dfs` -- depth-first search

The _depth-first search_ is implemented in `./dfs`.
For example:

    var Graph = require("libgraph/Graph"),
        gener = require("libgraph/generators"),
        dfs   = require("libgraph/dfs");
    var grid = new Graph(gener.grid(3,3));
    console.log(dfs(grid,'v1x1'));
    // { visit: 
    //   { v1x1: { discoveryTime: 1, treeEdge: undefined, closeTime: 8 },
    //     v1x2: { discoveryTime: 2, treeEdge: 7, closeTime: 5 },
    //     v2x2: { discoveryTime: 3, treeEdge: 9, closeTime: 4 },
    //     v2x1: { discoveryTime: 6, treeEdge: 8, closeTime: 7 } },
    //  treeEdges: [ 7, 9, 8 ],
    //  crossEdges: [ 11 ],
    //  backEdges: [] }

## `libgraph/topo-order` -- orders vertices topologicaly

Outputs a topologicaly ordered list of vertices of an __acyclic__ graph.

Example:

     var Graph = require("libgraph/Graph"),
         gener = require("libgraph/generators"),
         topo  = require("libgraph/topo-order");
     var grid = new Graph(gener.grid());
     console.log(grid);
     /* output: Graph {
       edges: 
        [ { src: 'v0x0', dst: 'v0x1' },
          { src: 'v0x0', dst: 'v1x0' },
          { src: 'v0x1', dst: 'v1x1' },
          { src: 'v1x0', dst: 'v1x1' } ],
       vertices: 
        { v0x0: { _rem: 'discovered' },
          v0x1: { _rem: 'discovered' },
          v1x0: { _rem: 'discovered' },
          v1x1: { _rem: 'discovered' } },
       src: { v0x0: [ 0, 1 ], v0x1: [ 2 ], v1x0: [ 3 ] },
       dst: { v0x1: [ 0 ], v1x0: [ 1 ], v1x1: [ 2, 3 ] } }
     */
     console.log(topo(grid));
     /* output: [ 'v0x0', 'v1x0', 'v0x1', 'v1x1' ] */

## `libgraph/dijkstra` -- Dijkstra shortest-path algorithm

Example:

     var Graph = require("libgraph/Graph"),
         gener = require("libgraph/generators"),
         dijkstra = require("libgraph/dijkstra");
     var cube = new Graph(gener.bin_cube(3));
     console.log(cube.edges);
     /* output:
     [ { src: '000', dst: '100' },
       { src: '001', dst: '101' },
       { src: '010', dst: '110' },
       { src: '011', dst: '111' },
       { src: '000', dst: '010' },
       { src: '001', dst: '011' },
       { src: '100', dst: '110' },
       { src: '101', dst: '111' },
       { src: '100', dst: '101' },
       { src: '110', dst: '111' },
       { src: '000', dst: '001' },
       { src: '010', dst: '011' } ] */
     var shortestPathsInHops = dijkstra(cube);
     var shortestPathsDataStructure = shortestPathsInHops.from('011');
     console.log(JSON.stringify(shortestPathsDataStructure));
     /* output: 
      {"src":"011","data":{"111":{"last":[3],"distance":1},"011":{"last":[],"distance":0}}} */
     var shortestPathEdges = shortestPathsInHops.from('000').edgesTo('011');
     console.log(JSON.stringify(shortestPathEdges));
     /* output: [11,5,4,10] */
     var shortestPathDAG = new Graph(shortestPathEdges.map(function(e){return cube.edges[e];}));
     console.log(shortestPathDAG.edges);
     /* output: 
     [ { src: '010', dst: '011' },
       { src: '001', dst: '011' },
       { src: '000', dst: '010' },
       { src: '000', dst: '001' } ] */

## `libgraph/bellman-ford` -- Bellman-Ford shortest-paths algorithm



