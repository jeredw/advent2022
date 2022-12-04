import std/strscans

type Interval = (int, int)
type Assignment = (Interval, Interval)

proc readAssignments(filename: string): seq[Assignment] =
  result = @[]
  for line in filename.lines():
    var a0, a1, b0, b1: int;
    assert scanf(line, "$i-$i,$i-$i", a0, a1, b0, b1)
    result.add(((a0, a1), (b0, b1)))

proc contains(a: Interval, x: int): bool =
  x >= a[0] and x <= a[1]

proc contains(a, b: Interval): bool =
  contains(b, a[0]) and contains(b, a[1])

proc overlaps(a, b: Interval): bool =
  not (a[1] < b[0] or a[0] > b[1])

proc solvePart1(assignments: seq[Assignment]): int =
  result = 0
  for (a, b) in assignments:
    if contains(a, b) or contains(b, a):
      result += 1

proc solvePart2(assignments: seq[Assignment]): int =
  result = 0
  for (a, b) in assignments:
    if overlaps(a, b):
      result += 1

let testAssignments = readAssignments("day4-test.txt")
assert solvePart1(testAssignments) == 2
assert solvePart2(testAssignments) == 4

let assignments = readAssignments("day4-input.txt")
echo solvePart1(assignments)
echo solvePart2(assignments)