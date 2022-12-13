import std/strutils
import std/algorithm

type
  NodeKind = enum
    nkInt,
    nkList
  Node = ref object
    case kind: NodeKind
    of nkInt: intVal: int
    of nkList: listVal: seq[Node]
    marked: bool

proc intNode(value: int): Node =
  Node(kind: nkInt, intVal: value)

proc listNode(value: seq[Node]): Node =
  Node(kind: nkList, listVal: value)

proc parseList(line: string, pos: int = 0, mark: bool = false): (Node, int) =
  var pos = pos
  if pos >= len(line) - 1:
    raise
  if line[pos] != '[':
    raise
  pos += 1
  var list = listNode(@[])
  if mark:
    list.marked = true
  while pos < len(line):
    case line[pos]
    of '[':
      var (value, nextPos) = parseList(line, pos)
      list.listVal.add(value)
      pos = nextPos
    of ']':
      break
    of '0'..'9':
      var value = 0
      while line[pos] in '0'..'9':
        value = 10 * value + ord(line[pos]) - ord('0')
        pos += 1
        if pos >= len(line):
          raise
      list.listVal.add(intNode(value))
      if line[pos] != ',' and line[pos] != ']':
        raise
    of ',':
      pos += 1
    else:
      raise
  if line[pos] != ']':
    raise
  return (list, pos + 1)

proc printList(list: Node): void =
  assert list.kind == nkList
  stdout.write '['
  var first = true
  for item in list.listVal:
    if not first:
      stdout.write ','
    case item.kind
    of nkList:
      printList(item)
    of nkInt:
      stdout.write item.intVal
    first = false
  stdout.write ']'

proc readListPairs(filename: string): seq[(Node, Node)] =
  result = @[]
  let file = open(filename)
  defer: file.close()
  while true:
    let (pair1, _) = parseList(file.readLine())
    let (pair2, _) = parseList(file.readLine())
    result.add((pair1, pair2))
    if file.endOfFile():
      return
    assert file.readLine().isEmptyOrWhitespace()

proc compare(left, right: Node): int =
  if left.kind == nkInt and right.kind == nkInt:
    return left.intVal - right.intVal
  if left.kind == nkList and right.kind == nkList:
    let numLeft = len(left.listVal)
    let numRight = len(right.listVal)
    for i in 0 ..< max(numLeft, numRight):
      if i < numLeft and i < numRight:
        let test = compare(left.listVal[i], right.listVal[i])
        if test != 0:
          return test
      elif i >= numLeft and i < numRight:
        return -1
      else:
        return 1
    return 0
  if left.kind == nkInt:
    return compare(listNode(@[intNode(left.intVal)]), right)
  return compare(left, listNode(@[intNode(right.intVal)]))

proc collect(pairs: seq[(Node, Node)]): seq[Node] =
  result = @[]
  for (left, right) in pairs:
    result.add(left)
    result.add(right)

proc solvePart1(pairs: seq[(Node, Node)]): int =
  var index = 1
  result = 0
  for (left, right) in pairs:
    if compare(left, right) < 0:
      result += index
    index += 1

proc solvePart2(pairs: seq[(Node, Node)]): int =
  var packets = collect(pairs)
  let (divider1, _) = parseList("[[2]]", mark = true)
  let (divider2, _) = parseList("[[6]]", mark = true)
  packets.add(divider1)
  packets.add(divider2)
  var index = 1
  result = 1
  for p in sorted(packets, compare):
    if p.marked:
      result *= index
    index += 1

let test = readListPairs("day13-test.txt")
assert solvePart1(test) == 13
assert solvePart2(test) == 140

let input = readListPairs("day13-input.txt")
echo solvePart1(input)
echo solvePart2(input)
