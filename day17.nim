import std/bitops
import std/strutils

const shapes = @[
  @[0b0_0011110_0],
  @[0b0_0001000_0,
    0b0_0011100_0,
    0b0_0001000_0],
  @[0b0_0000100_0,
    0b0_0000100_0,
    0b0_0011100_0],
  @[0b0_0010000_0,
    0b0_0010000_0,
    0b0_0010000_0,
    0b0_0010000_0],
  @[0b0_0011000_0,
    0b0_0011000_0],
]

proc printGrid(grid: seq[int]): void =
  for i in countdown(len(grid) - 1, 0):
    for bit in countdown(7, 1):
      if bitand(grid[i], 1 shl bit) != 0:
        stdout.write '#'
      else:
        stdout.write '.'
    stdout.write '\n'

proc shift(bitmap: int, amount: int): int =
  if amount == 0:
    return bitmap
  if amount < 0:
    return bitmap shl -amount
  return bitmap shr amount

proc playCrappyTetris(numRocks: int, jets: string): (int, seq[int]) =
  let empty = 0b1_0000000_1
  var deltas: seq[int] = @[]
  var grid: seq[int] = @[]
  var maxY = -1
  var lastMaxY = 0
  var j = 0
  for i in 0 ..< numRocks:
    let rock = shapes[i mod len(shapes)]
    let height = len(rock)
    while len(grid) <= 3 + maxY + height:
      grid.add(empty)
    var top = 3 + maxY + height
    var shiftAmount = 0
    for y in 0 ..< height:
      grid[top - y] = bitor(grid[top - y], rock[y])
    var stuck = false
    while not stuck:
      for y in 0 ..< height:
        grid[top - y] = bitxor(grid[top - y], shift(rock[y], shiftAmount))
      var newShiftAmount = shiftAmount + (if jets[j] == '>': 1 else: -1)
      j = (j + 1) mod len(jets)
      stuck = false
      for y in 0 ..< height:
        if bitand(grid[top - y], shift(rock[y], newShiftAmount)) != 0:
          stuck = true
      if not stuck:
        shiftAmount = newShiftAmount
      for y in 0 ..< height:
        grid[top - y] = bitor(grid[top - y], shift(rock[y], shiftAmount))
      if top == height - 1:
        break
      stuck = false
      for y in 0 ..< height:
        grid[top - y] = bitxor(grid[top - y], shift(rock[y], shiftAmount))
      for y in 0 ..< height:
        if bitand(grid[(top - 1) - y], shift(rock[y], shiftAmount)) != 0:
          stuck = true
      if not stuck:
        top -= 1
      for y in 0 ..< height:
        grid[top - y] = bitor(grid[top - y], shift(rock[y], shiftAmount))
    for y in countdown(len(grid) - 1, 0):
      if grid[y] != empty:
        maxY = y
        break
    deltas.add(1 + maxY - lastMaxY)
    lastMaxY = 1 + maxY
  return (1 + maxY, deltas)

proc findCycle(deltas: seq[int]): (int, int) =
  for start in 1 .. len(deltas):
    for period in 10 .. 10000:
      var found = true
      for i in 0 .. period:
        if deltas[start + i] != deltas[start + period + i]:
          found = false
          break
      if found:
        return (start, period)
  return (0, 0)

proc playCrappyTetrisCyclically(numRocks: int64, jets: string): int64 =
  let (_, deltas) = playCrappyTetris(100000, jets)
  let (start, period) = findCycle(deltas)
  assert start > 0 and period > 0
  var onePeriodSum = 0'i64
  for i in start ..< start + period:
    onePeriodSum += deltas[i]
  result = 0'i64
  for i in 0 ..< start:
    result += deltas[i]
  result += onePeriodSum * ((numRocks - start) div period)
  for i in 0 ..< (numRocks - start) mod period:
    result += deltas[start + i]

let test = ">>><<><>><<<>><>>><<<>>><<<><<<>><>><<>>"
let (answer1, _) = playCrappyTetris(2022, test)
assert answer1 == 3068
assert playCrappyTetrisCyclically(2022'i64, test) == 3068'i64
assert playCrappyTetrisCyclically(1000000000000'i64, test) == 1514285714288'i64

let input = readFile("day17-input.txt").strip()
let (answer2, _) = playCrappyTetris(2022, input)
echo answer2
echo playCrappyTetrisCyclically(1000000000000'i64, input)