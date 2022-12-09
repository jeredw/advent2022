import std/strutils
import std/sequtils

type Forest = seq[seq[int]]

proc readForest(filename: string): Forest =
  result = @[]
  for line in filename.lines():
    var row: seq[int] = @[]
    for char in line.strip():
      row.add(ord(char) - ord('0'))
    result.add(row)

proc countVisible(forest: Forest): int =
  let n = len(forest)
  var visible: seq[seq[bool]] = @[]
  for y in 0 .. n-1:
    visible.add(newSeq[bool](n))
  var up = newSeqWith(n, -1)
  var down = newSeqWith(n, -1)
  for j in 0 .. n-1:
    var left = -1
    var right = -1
    for i in 0 .. n-1:
      let (x, y, xx, yy) = (i, j, n-1-i, n-1-j)
      if forest[y][x] > left:
        left = forest[y][x]
        visible[y][x] = true
      if forest[y][x] > up[x]:
        up[x] = forest[y][x]
        visible[y][x] = true
      if forest[yy][xx] > right:
        right = forest[yy][xx]
        visible[yy][xx] = true
      if forest[yy][xx] > down[xx]:
        down[xx] = forest[yy][xx]
        visible[yy][xx] = true
  var numVisible = 0
  for j in 0 .. n-1:
    for i in 0 .. n-1:
      if visible[j][i]:
        numVisible += 1
  return numVisible

proc scan(forest: Forest, n, ix, iy, dx, dy: int): int =
  var (x, y) = (ix, iy)
  let tree = forest[y][x]
  for i in 1 .. n-1:
    y += dy
    x += dx
    if y == 0 or y == n-1 or x == 0 or x == n-1:
      return i
    if forest[y][x] >= tree:
      return i

proc mostScenic(forest: Forest): int =
  let n = len(forest)
  const dir = @[(-1, 0), (1, 0), (0, -1), (0, 1)]
  result = 0
  for j in 0 .. n-1:
    for i in 0 .. n-1:
      if i == 0 or j == 0 or i == n-1 or j == n-1:
        continue
      var score = 1
      for (dx, dy) in dir:
        let dist = scan(forest, n, i, j, dx, dy)
        score *= dist
      if score > result:
        result = score

let test = readForest("day8-test.txt")
assert countVisible(test) == 21
assert mostScenic(test) == 8

let input = readForest("day8-input.txt")
echo countVisible(input)
echo mostScenic(input)
