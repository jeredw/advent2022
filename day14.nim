import std/tables
import std/strutils
import std/sequtils

type Point = tuple[x: int, y: int]
type Material = enum
  air
  rock
  sand
type Map = ref object
  grid: Table[Point, Material]
  xMin: int
  xMax: int
  yMin: int
  yMax: int

proc sign(x: int): int =
  result = if x < 0: -1 elif x > 0: 1 else: 0

proc readScan(filename: string): Map =
  result = Map(grid: initTable[Point, Material](), xMin: 10000, yMin: 10000)
  for line in filename.lines():
    var (x, y) = (0, 0)
    for p in line.split(" -> "):
      let q = p.split(',').toSeq().map(parseInt)
      let (toX, toY) = (q[0], q[1])
      if x != 0 and y != 0:
        while true:
          result.grid[(x, y)] = rock
          if x < result.xMin:
            result.xMin = x
          if x > result.xMax:
            result.xMax = x
          if y > result.yMax:
            result.yMax = y
          if y < result.yMin:
            result.yMin = y
          if x == toX and y == toY:
            break
          x += sign(toX - x)
          y += sign(toY - y)
      (x, y) = (toX, toY)

proc drawMap(map: Map): void =
  for y in map.yMin-1 .. map.yMax+1:
    for x in map.xMin-1 .. map.xMax+1:
      let ch = case map.grid.getOrDefault((x, y), air)
      of air: '.'
      of rock: '#'
      of sand: 'o'
      stdout.write ch
    stdout.write '\n'

const source: Point = (500, 0)

proc at(map: Map, p: Point, assumeInfiniteFloor: bool): Material =
  if assumeInfiniteFloor and p.y == map.yMax + 2:
    return rock
  return map.grid.getOrDefault((p.x, p.y), air)

proc flow(inputMap: Map, assumeInfiniteFloor: bool = false): int =
  var map = deepCopy(inputMap)
  result = 0
  var p = source
  map.grid[p] = sand
  while assumeInfiniteFloor or p.y < map.yMax:
    if at(map, (p.x, p.y + 1), assumeInfiniteFloor) == air:
      map.grid[p] = air
      p.y += 1
    elif at(map, (p.x - 1, p.y + 1), assumeInfiniteFloor) == air:
      map.grid[p] = air
      p.x -= 1
      p.y += 1
    elif at(map, (p.x + 1, p.y + 1), assumeInfiniteFloor) == air:
      map.grid[p] = air
      p.x += 1
      p.y += 1
    else:
      result += 1
      if p == source:
        break
      p = source
    map.grid[p] = sand

let test = readScan("day14-test.txt")
assert flow(test) == 24
assert flow(test, assumeInfiniteFloor = true) == 93

let input = readScan("day14-input.txt")
echo flow(input)
echo flow(input, assumeInfiniteFloor = true)
