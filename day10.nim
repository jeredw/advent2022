import std/strutils

type Operation = enum
  noop  # no-op, do nothing
  addx  # add argument to x
type Program = seq[tuple[operation: Operation, argument: int]]

proc readProgram(filename: string): Program =
  result = @[]
  for line in filename.lines:
    let fields = line.split(" ")
    case fields[0]
    of "noop":
      result.add((operation: noop, argument: 0))
    of "addx":
      result.add((operation: addx, argument: parseInt(fields[1])))
    else:
      raise

proc runProgram(program: Program, draw: bool = false): int =
  var x = 1
  var beam = 0
  var cycle = 1
  var signalStrength = 0
  proc tick(): void =
    if draw:
      if beam == 0 and cycle > 1:
        stdout.write "\n"
      if beam >= x - 1 and beam <= x + 1:
        stdout.write "#"
      else:
        stdout.write "."
    if (cycle - 20) mod 40 == 0:
      signalStrength += cycle * x
    cycle += 1
    beam = (beam + 1) mod 40
  for instruction in program:
    case instruction.operation
    of noop:
      tick()
    of addx:
      tick()
      tick()
      x += instruction.argument
  if draw:
    echo ""
  return signalStrength

let test = readProgram("day10-test.txt")
assert runProgram(test) == 0
let test2 = readProgram("day10-test2.txt")
assert runProgram(test2) == 13140
discard runProgram(test2, draw = true)

let input = readProgram("day10-input.txt")
echo runProgram(input)
discard runProgram(input, draw = true)