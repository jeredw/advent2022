import std/sequtils
import std/strutils
import std/sets
import std/tables

const infinity = 1000000

type Point = tuple[x: int, y: int]
type Map = ref object
  height: seq[string]
  start: Point
  goal: Point

proc readMap(filename: string): Map =
  var height = toSeq(readFile(filename).splitLines())
  # to simplify boundary tests, pad heightmap with sentinel '~',
  # which is more than 1 higher than 'z'
  let padding = join(newSeqWith(len(height[0]), "~"))
  height.insert(padding, 0)
  height.add(padding)
  for y in 0 ..< len(height):
    height[y].insert("~", 0)
    height[y].add('~')
  # find start and goal, and change them to 'a' and 'z' respectively
  var start = (0, 0)
  var goal = (0, 0)
  for y in 0 ..< len(height):
    for x in 0 ..< len(height[0]):
      let here = height[y][x]
      if here == 'S':
        start = (x, y)
        height[y][x] = 'a'
      elif here == 'E':
        goal = (x, y)
        height[y][x] = 'z'
  Map(height: height, start: start, goal: goal)

proc distanceToGoal(p: Point, map: Map): int =
  abs(p.x - map.goal.x) + abs(p.y - map.goal.y)

proc search(start: Point, map: Map): int =
  var cost = {start: 0}.toTable
  var estimate = {start: distanceToGoal(start, map)}.toTable
  var closed = initHashSet[Point]()
  var open = [start].toHashSet()
  while len(open) > 0:
    var p: Point
    var best = infinity
    for q in open:
      if estimate[q] < best:
        best = estimate[q]
        p = q
    if p == map.goal:
      return cost[p]
    open.excl(p)
    closed.incl(p)
    let here = ord(map.height[p.y][p.x])
    let neighbors: seq[Point] = @[(p.x - 1, p.y), (p.x + 1, p.y), (p.x, p.y - 1), (p.x, p.y + 1)]
    for q in neighbors:
      if closed.contains(q):
        continue
      if ord(map.height[q.y][q.x]) > here + 1:
        continue
      let costHere = cost[p] + 1
      if not open.contains(q):
        open.incl(q)
      elif costHere >= cost[q]:
        continue
      cost[q] = costHere
      estimate[q] = costHere + distanceToGoal(q, map)
  return infinity

proc searchFromAllStartingPoints(map: Map): int =
  result = infinity
  for y in 1 ..< len(map.height)-1:
    for x in 1 ..< len(map.height[0])-1:
      if map.height[y][x] == 'a':
        let cost = search((x, y), map)
        if cost < result:
          result = cost

let test = readMap("day12-test.txt")
assert search(test.start, test) == 31
assert searchFromAllStartingPoints(test) == 29

let input = readMap("day12-input.txt")
echo search(input.start, input)
echo searchFromAllStartingPoints(input)