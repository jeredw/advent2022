import std/strscans
import std/strutils
import std/sequtils

type Stack = seq[char]
type Move = tuple[num: int, from_stack: int, to_stack: int]

proc readProblem(filename: string): (seq[Stack], seq[Move]) =
  var readingStacks = true
  var stacks: seq[Stack] = @[]
  var moves: seq[Move] = @[]
  for line in filename.lines:
    if line.isEmptyOrWhitespace():
      readingStacks = false
      continue
    if readingStacks:
      let numStacks = len(line) div 4  # 4 chars per stack in the diagram
      if len(stacks) == 0:
        for i in 0 .. numStacks:
          stacks.add(@[])
      for i in 0 .. numStacks:
        let j = 4 * i + 1
        let ch = line[j]
        if ch in '1'..'9':  # ignore labels beneath stacks
          break
        if ch != ' ':
          stacks[i].insert(ch, 0)
    else:  # not readingStacks
      var num, from_stack, to_stack: int
      assert scanf(line, "move $i from $i to $i", num, from_stack, to_stack)
      moves.add((num, from_stack, to_stack))
  return (stacks, moves)

proc copyStacks(stacks: seq[Stack]): seq[Stack] =
  result = @[]
  for stack in stacks:
    var copyOfStack: Stack = @[]
    for j in 0 ..< len(stack):
      copyOfStack.add(stack[j])
    result.add(copyOfStack)

proc solvePart1(problem: (seq[Stack], seq[Move])): string =
  let (inputStacks, moves) = problem
  var stacks = copyStacks(inputStacks)
  for (num, from_stack, to_stack) in moves:
    for i in 0 ..< num:
      let item = stacks[from_stack - 1].pop()
      stacks[to_stack - 1].add(item)
  result = ""
  for stack in stacks:
    result.add(stack[^1])

proc solvePart2(problem: (seq[Stack], seq[Move])): string =
  let (inputStacks, moves) = problem
  var stacks = copyStacks(inputStacks)
  for (num, from_stack, to_stack) in moves:
    let size = len(stacks[from_stack - 1])
    let itemRange = size - num .. size - 1
    let items = stacks[from_stack - 1][itemRange]
    stacks[from_stack - 1].delete(itemRange)
    stacks[to_stack - 1].add(items)
  result = ""
  for stack in stacks:
    result.add(stack[^1])

let testProblem = readProblem("day5-test.txt")
assert solvePart1(testProblem) == "CMZ"
assert solvePart2(testProblem) == "MCD"

let problem = readProblem("day5-input.txt")
echo solvePart1(problem)
echo solvePart2(problem)
