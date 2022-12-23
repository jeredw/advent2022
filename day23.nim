import std/sets
import std/tables

type
  Position = tuple[x: int, y: int]
  Grid = ref object
    elves: HashSet[Position]
    lower: Position
    upper: Position

const infinity = 100000

proc putElfAt(grid: Grid, pos: Position): void =
  grid.elves.incl((pos.x, pos.y))
  grid.lower.x = min(grid.lower.x, pos.x)
  grid.lower.y = min(grid.lower.y, pos.y)
  grid.upper.x = max(grid.upper.x, pos.x)
  grid.upper.y = max(grid.upper.y, pos.y)

proc readGrid(filename: string): Grid =
  result = Grid(elves: initHashSet[Position](), lower: (infinity, infinity))
  var y = 0
  for line in filename.lines():
    for x in 0 ..< len(line):
      if line[x] == '#':
        result.putElfAt((x, y))
    y += 1

proc print(grid: Grid): void =
  for y in grid.lower.y .. grid.upper.y:
    for x in grid.lower.x .. grid.upper.x:
      if grid.elves.contains((x, y)):
        stdout.write '#'
      else:
        stdout.write '.'
    stdout.write '\n'

proc simulateOneRound(grid: Grid, startDirection: int): Grid =
  result = Grid(elves: initHashSet[Position](), lower: (infinity, infinity))
  var
    proposals = initCountTable[Position]()
    proposedTarget = initTable[Position, Position]()
  for (x, y) in grid.elves.items():
    var isolated = true
    for dx in @[-1, 0, 1]:
      for dy in @[-1, 0, 1]:
        if dx == 0 and dy == 0:
          continue
        if grid.elves.contains((x + dx, y + dy)):
          isolated = false
          break
    if not isolated:
      let neighbors = @[
        @[(x - 1, y - 1), (x, y - 1), (x + 1, y - 1)],  # north
        @[(x - 1, y + 1), (x, y + 1), (x + 1, y + 1)],  # south
        @[(x - 1, y - 1), (x - 1, y), (x - 1, y + 1)],  # west
        @[(x + 1, y - 1), (x + 1, y), (x + 1, y + 1)],  # east
      ]
      for d in 0 .. 3:
        let direction = (startDirection + d) mod 4
        var directionIsOccupied = false
        for p in neighbors[direction]:
          if grid.elves.contains(p):
            directionIsOccupied = true
            break
        if not directionIsOccupied:
          let target = neighbors[direction][1]
          proposals.inc(target)
          proposedTarget[(x, y)] = target
          break
  for (x, y) in grid.elves.items():
    if not proposedTarget.contains((x, y)):
      result.putElfAt((x, y))
      continue
    let target = proposedTarget[(x, y)]
    if proposals[target] == 1:
      result.putElfAt(target)
    else:
      result.putElfAt((x, y))

proc solvePart1(grid: Grid, rounds: int): int =
  var grid = grid
  for i in 0 .. rounds:
    #echo "---"
    #echo "round ", i
    #grid.print()
    grid = grid.simulateOneRound(i)
  #echo "---"
  #grid.print()
  return (grid.upper.x - grid.lower.x + 1) * (grid.upper.y - grid.lower.y + 1) - len(grid.elves)

proc solvePart2(grid: Grid): int =
  var grid = grid
  var i = 0
  while true:
    let newGrid = grid.simulateOneRound(i)
    i += 1
    if grid.elves == newGrid.elves:
      return i
    grid = newGrid

#let example = readGrid("day23-example.txt")
#discard simulate(example, 5)
let test = readGrid("day23-test.txt")
assert solvePart1(test, 10) == 110
assert solvePart2(test) == 20

let input = readGrid("day23-input.txt")
echo solvePart1(input, 10)
echo solvePart2(input)
