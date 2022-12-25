import std/sets
import std/tables

type
  Point = tuple[x: int, y: int, z: int, phase: int]
  Direction = enum
    north = 0
    east = 1
    south = 2
    west = 3
  Map = ref object
    blizzards: Table[Point, seq[Direction]]
    grid: seq[seq[seq[bool]]]
    width: int
    height: int
    depth: int

const deltas = @[(0, -1), (1, 0), (0, 1), (-1, 0)]
    
proc precomputeBlizzards(map: Map): void =
  map.depth = map.width * map.height
  for z in 0 ..< map.depth:
    map.grid.add(@[])
    var nextBlizzards = initTable[Point, seq[Direction]]()
    for p in map.blizzards.keys:
      for direction in map.blizzards[p]:
        let (dx, dy) = deltas[ord(direction)]
        var n: Point = (p.x + dx, p.y + dy, 0, 0)
        if n.x == map.width - 1: n.x = 1
        if n.x == 0: n.x = map.width - 2
        if n.y == map.height - 1: n.y = 1
        if n.y == 0: n.y = map.height - 2
        if nextBlizzards.contains(n):
          nextBlizzards[n].add(direction)
        else:
          nextBlizzards[n] = @[direction]
    map.blizzards = nextBlizzards
    for y in 0 ..< map.height:
      var row: seq[bool] = @[]
      for x in 0 ..< map.width:
        let blizzard = map.blizzards.contains((x, y, 0, 0))
        let edge = x == 0 or y == 0 or x == map.width - 1 or y == map.height - 1
        let start = x == 1 and y == 0
        let goal = x == map.width - 2 and y == map.height - 1
        row.add(blizzard or (edge and not (start or goal)))
      map.grid[^1].add(row)

proc readMap(filename: string): Map =
  result = Map(grid: @[], blizzards: initTable[Point, seq[Direction]]())
  result.grid.add(@[])
  var y = 0
  for line in filename.lines():
    if result.width == 0:
      result.width = len(line)
    assert len(line) == result.width
    assert line[0] == '#'
    assert line[^1] == '#'
    var row: seq[bool] = @[]
    for x in 0 ..< result.width:
      case line[x]
      of '.':
        row.add(false)
      of '#':
        row.add(true)
      of '^':
        row.add(true)
        result.blizzards[(x, y, 0, 0)] = @[north]
      of '>':
        row.add(true)
        result.blizzards[(x, y, 0, 0)] = @[east]
      of 'v':
        row.add(true)
        result.blizzards[(x, y, 0, 0)] = @[south]
      of '<':
        row.add(true)
        result.blizzards[(x, y, 0, 0)] = @[west]
      else:
        raise
    result.grid[0].add(row)
    y += 1
  result.height = y
  precomputeBlizzards(result)

proc print(map: Map, z: int): void =
  let grid = map.grid[z]
  for y in 0 ..< map.height:
    for x in 0 ..< map.width:
      if grid[y][x]:
        stdout.write 'x'
      else:
        stdout.write '.'
    stdout.write '\n'

proc distanceToGoal(p, start, goal: Point): int =
  if p.phase == 0:
    return 3000 + abs(p.x - goal.x) + abs(p.y - goal.y)
  if p.phase == 1:
    return 2000 + abs(p.x - start.x) + abs(p.y - start.y)
  return 1000 + abs(p.x - goal.x) + abs(p.y - goal.y)

const infinity = 100000

proc search(start, goal: Point, map: Map): int =
  var cost = {start: 0}.toTable
  var estimate = {start: distanceToGoal(start, start, goal)}.toTable
  var closed = initHashSet[Point]()
  var open = [start].toHashSet()
  while len(open) > 0:
    var p: Point
    var best = infinity
    for q in open:
      if estimate[q] < best:
        best = estimate[q]
        p = q
    if p.phase == 2 and p.x == goal.x and p.y == goal.y:
      return cost[p]
    open.excl(p)
    closed.incl(p)
    let nz = (p.z + 1) mod map.depth
    var np = if p.phase == 0 and p.x == goal.x and p.y == goal.y:
      1
    elif p.phase == 1 and p.x == start.x and p.y == start.y:
      2
    else:
      p.phase
    let neighbors: seq[Point] = @[
      (p.x, p.y, nz, np),
      (p.x - 1, p.y, nz, np),
      (p.x + 1, p.y, nz, np),
      (p.x, p.y - 1, nz, np),
      (p.x, p.y + 1, nz, np)
    ]
    for q in neighbors:
      if q.x < 0 or q.y < 0 or q.x >= map.width or q.y >= map.height:
        continue
      if closed.contains(q):
        continue
      if map.grid[q.z][q.y][q.x]:
        continue
      let costHere = cost[p] + 1
      if not open.contains(q):
        open.incl(q)
      elif costHere >= cost[q]:
        continue
      cost[q] = costHere
      estimate[q] = costHere + distanceToGoal(q, start, goal)
  return infinity

let test = readMap("day24-test.txt")
assert search(start = (1, 0, 0, 2), goal = (test.width - 2, test.height - 1, 0, 2), test) == 18
assert search(start = (1, 0, 0, 0), goal = (test.width - 2, test.height - 1, 0, 2), test) == 54

let input = readMap("day24-input.txt")
echo search(start = (1, 0, 0, 2), goal = (input.width - 2, input.height - 1, 0, 2), input)
echo search(start = (1, 0, 0, 0), goal = (input.width - 2, input.height - 1, 0, 2), input)
