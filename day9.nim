import std/strscans
import std/sets

type Step = tuple[dir: char, num_steps: int]
type Path = seq[Step]
type Point = tuple[x: int, y: int]

proc readPath(filename: string): Path =
  result = @[]
  for line in filename.lines():
    var step: Step
    assert scanf(line, "$c $i", step.dir, step.num_steps)
    result.add(step)

proc sign(x: int): int =
  result = if x < 0: -1 elif x > 0: 1 else: 0

proc tracePath(path: Path, n: int): int =
  var rope: seq[Point] = newSeq[Point](n)
  var visited: HashSet[Point] = toHashSet(@[(0, 0)])
  for step in path:
    let (dir, num_steps) = step
    for i in 0 ..< num_steps:
      case dir
      of 'R': rope[0].x += 1
      of 'L': rope[0].x -= 1
      of 'U': rope[0].y += 1
      of 'D': rope[0].y -= 1
      else: raise
      for j in 1 ..< n:
        let (dx, dy) = (rope[j-1].x - rope[j].x, rope[j-1].y - rope[j].y)
        if abs(dx) == 2 or abs(dy) == 2:
          rope[j].x += sign(dx)
          rope[j].y += sign(dy)
      visited.incl(rope[n-1])
  return len(visited)

let test = readPath("day9-test.txt")
assert tracePath(test, 2) == 13
assert tracePath(test, 10) == 1

let test2 = readPath("day9-test2.txt")
assert tracePath(test2, 10) == 36

let input = readPath("day9-input.txt")
echo tracePath(input, 2)
echo tracePath(input, 10)
