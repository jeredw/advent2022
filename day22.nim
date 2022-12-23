import std/strutils
import std/tables

type
  Position = tuple[row: int, column: int]
  Facing = enum
    right = 0
    down = 1
    left = 2
    up = 3
  Map = Table[Position, bool]
  Step = tuple[turn: char, move: int]
  Path = seq[Step]
  Input = tuple[map: Map, start: Position, size: Position, path: Path]
  Face = ref object
    origin: Position
    map: seq[seq[bool]]
    align: seq[tuple[face: int, edge: int]]
  Cube = ref object
    size: int
    faces: seq[Face]

const direction: seq[Position] = @[(0, 1), (1, 0), (0, -1), (-1, 0)]
const open = false
const wall = true

proc readInput(filename: string): Input =
  result.map = initTable[Position, bool]()
  result.size = (0, 0)
  result.start = (-1, -1)
  result.path = @[]
  var row = 0
  var readingPath = false
  for line in filename.lines():
    if readingPath:
      var i = 0
      let n = len(line)
      while i < n:
        case line[i]
        of 'R':
          result.path.add(('R', 0))
          i += 1
        of 'L':
          result.path.add(('L', 0))
          i += 1
        of '0' .. '9':
          var number = ord(line[i]) - ord('0')
          i += 1
          while i < n and line[i] in '0' .. '9':
            number = (number * 10) + (ord(line[i]) - ord('0'))
            i += 1
          result.path.add(('F', number))
        else: raise
      break
    if line.isEmptyOrWhitespace():
      readingPath = true
      continue
    let numColumns = len(line) - 1  # omit newline
    for column in 0 .. numColumns:
      case line[column]
      of ' ':
        continue
      of '.':
        if row == 0 and result.start == (-1, -1):
          result.start = (row, column)
        result.map[(row, column)] = open
      of '#':
        result.map[(row, column)] = wall
      else:
        raise
    row += 1
    result.size.column = max(result.size.column, numColumns)
    result.size.row = max(result.size.row, row)

proc printInput(input: Input, trace: Table[Position, char]): void =
  for row in 0 .. input.size.row:
    for column in 0 .. input.size.column:
      if trace.contains((row, column)):
        stdout.write trace[(row, column)]
      elif not input.map.contains((row, column)):
        stdout.write ' '
      elif input.map[(row, column)] == wall:
        stdout.write '#'
      else:
        stdout.write '.'
    stdout.write '\n'
  for step in input.path:
    if step.turn == 'F':
      stdout.write step.move
    else:
      stdout.write step.turn
  stdout.write '\n'

proc walk(pos: Position, facing: int): Position =
  result.row = pos.row + direction[facing].row
  result.column = pos.column + direction[facing].column

proc followPath(input: Input): tuple[pos: Position, facing: int] =
  var trace = initTable[Position, char]()
  var pos = input.start
  var facing = 0
  for step in input.path:
    assert input.map[pos] == open
    if step.turn == 'F':
      var move = step.move
      while move > 0:
        var next = walk(pos, facing)
        if not input.map.contains(next):  # wrap
          case facing
          of ord(right): next.column = 0
          of ord(down): next.row = 0
          of ord(left): next.column = input.size.column
          of ord(up): next.row = input.size.row
          else: raise
          while not input.map.contains(next):
            next = walk(next, facing)
            assert next != pos
        if input.map[next] == wall:
          break
        trace[pos] = ">v<^"[facing]
        pos = next
        move -= 1
    elif step.turn == 'R':
      facing = (facing + 1) mod 4
    elif step.turn == 'L':
      facing = facing - 1
      if facing < 0:
        facing += 4
    trace[pos] = ">v<^"[facing]
    #echo "---"
    #printInput(input, trace)
  return (pos, facing)

proc solvePart1(input: Input): int =
  let (pos, facing) = followPath(input)
  return (pos.row + 1) * 1000 + 4 * (pos.column + 1) + facing

# oriented edge numbering:
#     0
#   ^--->
# 3 |   | 1
#   <---v
#     2
const topEdge = 0
const rightEdge = 1
const bottomEdge = 2
const leftEdge = 3

proc fold(input: Input, size: int): Cube =
  result = Cube(size: size, faces: @[])
  # slice the map into cube faces of dimension size^2
  let
    rows = input.size.row
    columns = input.size.column
  var faceAt = initTable[Position, int]()
  for j in 0 .. (rows div size):
    for i in 0 .. (columns div size):
      let (y0, x0) = (size * j, size * i)
      if input.map.contains((y0, x0)):
        var face = Face()
        let faceIndex = len(result.faces)
        face.origin = (y0, x0)
        face.map = @[]
        for y in 0 ..< size:
          var row: seq[bool] = @[]
          for x in 0 ..< size:
            let pos = (y0 + y, x0 + x)
            row.add(input.map[pos])
            faceAt[pos] = faceIndex
          face.map.add(row)
        face.align = @[(-1, -1), (-1, -1), (-1, -1), (-1, -1)]
        result.faces.add(face)
  assert len(result.faces) == 6
  # initialize edge alignment from map
  for face in result.faces:
    let
      up = (face.origin.row - 1, face.origin.column)
      left = (face.origin.row, face.origin.column - 1)
      down = (face.origin.row + size, face.origin.column + size - 1)
      right = (face.origin.row + size - 1, face.origin.column + size)
    if faceAt.contains(up):
      face.align[topEdge] = (faceAt[up], bottomEdge)
    if faceAt.contains(right):
      face.align[rightEdge] = (faceAt[right], leftEdge)
    if faceAt.contains(down):
      face.align[bottomEdge] = (faceAt[down], topEdge)
    if faceAt.contains(left):
      face.align[leftEdge] = (faceAt[left], rightEdge)
  # fold corners until all edges are aligned
  var folded = false
  while not folded:
    #echo "---"
    folded = true
    for i in 0 ..< len(result.faces):
      let face = result.faces[i]
      #echo i, ": ", face.origin, " ", face.align
      let
        up = face.align[topEdge].face
        right = face.align[rightEdge].face
        down = face.align[bottomEdge].face
        left = face.align[leftEdge].face
      if up == -1 or right == -1 or down == -1 or left == -1:
        folded = false
      if left != -1 and up != -1:
        let prevLeftEdge = (4 + face.align[leftEdge].edge - 1) mod 4
        let nextUpEdge = (face.align[topEdge].edge + 1) mod 4
        result.faces[left].align[prevLeftEdge] = (up, nextUpEdge)
        result.faces[up].align[nextUpEdge] = (left, prevLeftEdge)
      if right != -1 and up != -1:
        let prevUpEdge = (4 + face.align[topEdge].edge - 1) mod 4
        let nextRightEdge = (face.align[rightEdge].edge + 1) mod 4
        result.faces[right].align[nextRightEdge] = (up, prevUpEdge)
        result.faces[up].align[prevUpEdge] = (right, nextRightEdge)
      if right != -1 and down != -1:
        let prevRightEdge = (4 + face.align[rightEdge].edge - 1) mod 4
        let nextDownEdge = (face.align[bottomEdge].edge + 1) mod 4
        result.faces[right].align[prevRightEdge] = (down, nextDownEdge)
        result.faces[down].align[nextDownEdge] = (right, prevRightEdge)
      if left != -1 and down != -1:
        let prevDownEdge = (4 + face.align[bottomEdge].edge - 1) mod 4
        let nextLeftEdge = (face.align[leftEdge].edge + 1) mod 4
        result.faces[left].align[nextLeftEdge] = (down, prevDownEdge)
        result.faces[down].align[prevDownEdge] = (left, nextLeftEdge)

type CubePosition = tuple[face: int, pos: Position]

proc followPathOnCube(cube: Cube, input: Input): tuple[pos: Position, facing: int] =
  var trace = initTable[Position, char]()
  var at: CubePosition = (0, (0, 0))  # start on face 0 at origin
  var facing = 0  # right
  let M = cube.size - 1
  for step in input.path:
    assert cube.faces[at.face].map[at.pos.row][at.pos.column] == open
    if step.turn == 'F':
      var move = step.move
      while move > 0:
        let origin = cube.faces[at.face].origin
        let tracePos = (origin.row + at.pos.row, origin.column + at.pos.column)
        trace[tracePos] = ">v<^"[facing]
        var next: CubePosition = (at.face, walk(at.pos, facing))
        var nextFacing = facing
        if next.pos.row < 0:  # off top
          let (newFace, edge) = cube.faces[at.face].align[topEdge]
          let p = at.pos.column
          nextFacing = (edge + 1) mod 4
          next.face = newFace
          next.pos = [(0, M - p), (M - p, M), (M, p), (p, 0)][edge]
        elif next.pos.column > M:  # off right
          let (newFace, edge) = cube.faces[at.face].align[rightEdge]
          let p = at.pos.row
          nextFacing = (edge + 1) mod 4
          next.face = newFace
          next.pos = [(0, M - p), (M - p, M), (M, p), (p, 0)][edge]
        elif next.pos.row > M:  # off bottom
          let (newFace, edge) = cube.faces[at.face].align[bottomEdge]
          let p = at.pos.column
          nextFacing = (edge + 1) mod 4
          next.face = newFace
          next.pos = [(0, p), (p, M), (M, M - p), (M - p, 0)][edge]
        elif next.pos.column < 0:  # off left edge
          let (newFace, edge) = cube.faces[at.face].align[leftEdge]
          let p = at.pos.row
          nextFacing = (edge + 1) mod 4
          next.face = newFace
          next.pos = [(0, p), (p, M), (M, M - p), (M - p, 0)][edge]
        if cube.faces[next.face].map[next.pos.row][next.pos.column] == wall:
          break
        at = next
        facing = nextFacing
        move -= 1
    elif step.turn == 'R':
      facing = (facing + 1) mod 4
    elif step.turn == 'L':
      facing = (4 + facing - 1) mod 4
    let origin = cube.faces[at.face].origin
    let tracePos = (origin.row + at.pos.row, origin.column + at.pos.column)
    trace[tracePos] = ">v<^"[facing]
    #echo "---"
    #echo step
    #printInput(input, trace)
  let origin = cube.faces[at.face].origin
  let tracePos = (origin.row + at.pos.row, origin.column + at.pos.column)
  return (tracePos, facing)

proc solvePart2(input: Input, size: int): int =
  let cube = fold(input, size)
  let (pos, facing) = followPathOnCube(cube, input)
  return (pos.row + 1) * 1000 + 4 * (pos.column + 1) + facing

let test = readInput("day22-test.txt")
assert solvePart1(test) == 6032
assert solvePart2(test, 4) == 5031

let input = readInput("day22-input.txt")
echo solvePart1(input)
echo solvePart2(input, 50)
