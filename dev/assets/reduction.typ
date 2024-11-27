#import "@preview/cetz:0.2.2": canvas, draw, tree, plot
#set page(width: auto, height: auto, margin: 2pt)
#align(center, canvas({
  import draw: *
  for (x, y, text) in (
      (5, -1, "Independent Set"),
      (-4, -1, "QUBO (Spin Glass)"),
      (5, 1, "Set Packing"),
      (2, 3, "Dominating Set"),
      (-8, -1, "Max Cut"),
      (-2, 3, "Coloring"),
      (0, 1, "k-SAT"),
      (-4, 1, "Circuit SAT"),
      (-8, 1, "Vertex Matching"),
      (3, -3, "Independent Set on KSG"),
      (-4, -3, "QUBO on Grid"),
      (1, -1, "Integer Factorization"),
      (-5, 3, "Vertex Cover"),
      (-8, 3, "Set Cover")
    ){
    content((x, y), box(text, stroke:black, inset:7pt), name: text)
  }
  let arr = "straight"
  for (a, b, markstart, markend, color) in (
    ("Set Cover", "Vertex Cover", none, arr, black),
    ("Integer Factorization", "Circuit SAT", none, arr, black),
    ("Set Packing", "Independent Set", arr, arr, black),
    ("k-SAT", "Independent Set", none, arr, black),
    ("Independent Set on KSG", "Independent Set", arr, arr, black),
    ("Integer Factorization", "Circuit SAT", none, arr, black),
    ("Vertex Cover", "Set Cover", none, arr, black),
    ("Dominating Set", "k-SAT", arr, none, black),
    ("Coloring", "k-SAT", arr, none, black),
    ("Circuit SAT", "k-SAT", arr, none, black),
    ("Set Packing", "Independent Set", arr, arr, black),
    ("k-SAT", "Independent Set", none, arr, black),
    ("k-SAT", "QUBO (Spin Glass)", none, arr, black),
    ("Integer Factorization", "Independent Set on KSG", none, arr, black),
    ("k-SAT", "Circuit SAT", arr, none, black),
    ("Independent Set on KSG", "QUBO on Grid", arr, none, black),
    ("QUBO (Spin Glass)", "Max Cut", arr, arr, black),
    ("Vertex Matching", "Circuit SAT", arr, none, black),
    ("Vertex Cover", "Circuit SAT", arr, none, black),
    ("QUBO on Grid", "QUBO (Spin Glass)", arr, none, black),
  ){
    line(a, b, mark: (end: markend, start: markstart), stroke: color)
  }
  rect((-6, -4), (6, -2), stroke:(dash: "dashed"))
  content((-8.5, -3), [Low-dimensional topology])
}))
