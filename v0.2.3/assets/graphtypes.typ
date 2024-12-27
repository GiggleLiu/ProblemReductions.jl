#import "@preview/cetz:0.2.2": canvas, draw, tree, plot
#import "lib/graph.typ": show-grid-graph, grid-graph-locations, show-graph, spring-layout, show-udg-graph, udg-graph, random-regular-graph
#set page(width: auto, height: auto, margin: 5pt)

#align(center, canvas(length:0.6cm, {
  import draw: *
  show-grid-graph(8, 8, filling:0.8, unitdisk: 1.5, gridsize: 1.2, radius: 0.2)
  content((4, -1), [King's subgraph (grid graph)])

  // 3-regular graph
  set-origin((16, 4))
  let n = 50
  let edges = random-regular-graph(n, 3)
  let locs = spring-layout(n, edges, optimal_distance:0.8)
  show-graph(locs, edges)
  content((2, -5), [3-regular graph])
}))

