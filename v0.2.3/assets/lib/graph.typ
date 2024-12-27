#import "@preview/cetz:0.2.2": canvas, draw, tree, plot
#import "@preview/suiji:0.3.0": *

#let zeros(n) = range(n).map(_ => 0)
#let norm(v) = calc.sqrt(v.map(x => calc.pow(x, 2)).sum())
#let distance(a, b) = norm(a.zip(b).map(x => x.at(0) - x.at(1)))
#let show-graph(vertices, edges, radius:0.2) = {
  import draw: *
  for (k, (i, j)) in vertices.enumerate() {
    circle((i, j), radius:radius, name: str(k))
  }
  for (k, l) in edges {
    line(str(k), str(l))
  }
}

#let udg-graph(vertices, unit:1) = {
  let edges = ()
  for (k, (i, j)) in vertices.enumerate() {
    for (l, (a, b)) in vertices.enumerate() {
      if l < k and distance((i, j), (a, b)) <= unit {
        edges.push((k, l))
      }
    }
  }
  return edges
}

#let _suitible(edges, potential_edges) = {
  if potential_edges.len() == 0 {
    return true
  }
  let ks = potential_edges.keys().map(x=>int(x))
  for s1 in ks {
    for s2 in ks {
      if s1 == s2 {
        break
      }
      if s1 > s2 {
        (s1, s2) = (s2, s1)
      }
      if (s1, s2) not in edges {
        return true
      }
    }
  }
  return false
}

#let _try_creation(rng, n, d) = {
  let edges = ()
  let stubs = ()
  for i in range(n){
    for j in range(d){
      stubs.push(i)
    }
  }
  let counter = 0
  while stubs.len() > 0 {
    counter += 1
    let potential_edges = (:)
    (rng, stubs) = shuffle(rng, stubs)
     // stubiter = iter(stubs)
    for i in range(0, stubs.len(), step:2) {
      let (s1, s2) = (stubs.at(i), stubs.at(i+1))
      if s1 > s2 {
        (s1, s2) = (s2, s1)
      }
      if s1 != s2 and (s1, s2) not in edges {
        edges.push((s1, s2))
      } else {
        potential_edges.insert(str(s1), potential_edges.at(str(s1), default:0) + 1)
        potential_edges.insert(str(s2), potential_edges.at(str(s2), default:0) + 1)
      }
    }
    if not _suitible(edges, potential_edges) {
      return (rng, ())
    }
    stubs = ()
    for (e, ct) in potential_edges{
      for j in range(ct){
        stubs.push(int(e))
      }
    }
  }
  return (rng, edges)
}

#let random-regular-graph(n, d, seed:42) = {
  import draw: *
  let edges = ()
  let rng = gen-rng(seed)
  let target
  let degrees = zeros(n)
  assert.eq(calc.rem(n * d, 2), 0)
  assert(d < n)
  assert(d >= 0)

  if d == 0 {
    return edges
  }
  (rng, edges) = _try_creation(rng, n, d)
  while edges.len() == 0 {
    (rng, edges) = _try_creation(rng, n, d)
  }
  return edges
}

#let show-udg-graph(vertices, unit:1, radius:0.2) = {
  let edges = udg-graph(vertices, unit:unit)
  show-graph(vertices, edges, radius:radius)
}

#let grid-graph-locations(m, n, filling:1, gridsize: 1, seed:42, a:(1, 0), b:(0, 1)) = {
  let rng = gen-rng(seed)
  let (rng, rand) = uniform(rng, size:m*n)
  let locations = ()
  for i in range(m) {
    for j in range(n) {
      if rand.at(m * i + j) < filling {
        locations.push((i*gridsize*a.at(0) + j*gridsize*b.at(0), i*gridsize*a.at(1) + j*gridsize*b.at(1)))
      }
    }
  }
  return locations
}

#let show-grid-graph(m, n, filling:1, gridsize: 1, unitdisk:1.1, radius: 0.2, a:(1, 0), b:(0, 1)) = {
  import draw: *
  let locations = grid-graph-locations(m, n, filling:filling, gridsize: gridsize, a:a, b:b)
  show-udg-graph(locations, unit:unitdisk * gridsize, radius:radius)
}

#let spring-layout(n, edges, optimal_distance:2, seed:42) = {
  let locs = ()
  let rng = gen-rng(seed)
  for i in range(n) {
    let locs_i
    (rng, locs_i) = uniform(rng, size: 2)
    locs.push(locs_i)
  }
  let maxiter = 100
  let alpha0 = 2.0
  // Store forces and apply at end of iteration all at once
  //let force = range(n).map(_ => zeros(2))
  let xs = locs.map(x=>x.at(0))
  let ys = locs.map(x=>x.at(1))
  let fx = zeros(n)
  let fy = zeros(n)
  // Iterate maxiter times
  for iter in range(maxiter) {
    // Cool down
    let temp = alpha0 / (iter+1)
    // Calculate forces
    for i in range(n) {
      let fxi = 0
      let fyi = 0
      let xsi = xs.at(i)
      let ysi = ys.at(i)
      for j in range(n) {
        let xsj = xs.at(j)
        let ysj = ys.at(j)
        let dx = xsj - xsi
        let dy = ysj - ysi
        if i == j {
          continue
        }
        let dist = calc.max(calc.sqrt(dx * dx + dy * dy), 1e-5)
        let F_d = -calc.pow(dist, -2)
        if ((i, j) in edges) or ((j, i) in edges) {
          F_d = F_d + dist
        }
        fxi += F_d * dx
        fyi += F_d * dy
      }
      fx.at(i) = fxi
      fy.at(i) = fyi
    }
    // Now apply them, but limit to temperature
    for i in range(n) {
      let fxi = fx.at(i)
      let fyi = fy.at(i)
      let force_mag = calc.sqrt(fxi * fxi + fyi * fyi)
      let scale = calc.min(force_mag, temp) / force_mag
      xs.at(i) = fxi * scale + xs.at(i)
      ys.at(i) = fyi * scale + ys.at(i)
    }
  }
  return xs.zip(ys).map(x=>x.map(x=>x*optimal_distance))
}