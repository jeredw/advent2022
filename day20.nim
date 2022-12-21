import std/sequtils
import std/strutils

proc readFile(filename: string): seq[int64] =
  result = @[]
  for line in filename.lines():
    result.add(parseInt(line))

proc mix(input: seq[int64], order: seq[int]): (seq[int64], seq[int]) =
  let n = len(input)
  var mixed = input
  var order = order
  for i in 0 ..< n:
    let fromIndex = order.find(i)
    let value = mixed[fromIndex]
    # this index arithmetic took embarrassingly long to get right
    # - insert() inserts "before" the index, but we delete() first
    # - the position "before" 0 is n (n-1 because we delete() first)
    # - it is mod n - 1, not mod n
    # at one point i gave up and rewrote this using a doubly linked ring,
    # and i was 99% sure that it was correct.  and yet it was wrong.
    var toIndex = (fromIndex + value) mod (n - 1)
    if toIndex == 0 and value < 0:
      toIndex = n - 1
    if toIndex < 0:
      toIndex += n - 1
    mixed.delete(fromIndex)
    order.delete(fromIndex)
    mixed.insert(value, toIndex)
    order.insert(i, toIndex)
  return (mixed, order)

proc iota(n: int): seq[int] =
  result = @[]
  for i in 0 ..< n:
    result.add(i)

proc solvePart1(input: seq[int64]): int64 =
  let n = len(input)
  let (mixed, _) = mix(input, iota(n))
  let zeroIndex = mixed.find(0)
  return mixed[(zeroIndex + 1000) mod n] + mixed[(zeroIndex + 2000) mod n] + mixed[(zeroIndex + 3000) mod n]

proc solvePart2(input: seq[int64]): int64 =
  const key = 811589153'i64
  let n = len(input)
  var input2: seq[int64] = @[]
  for value in input:
    input2.add(value * key)
  var order = iota(n)
  for i in 1 .. 10:
    (input2, order) = mix(input2, order)
  let zeroIndex = input2.find(0)
  return input2[(zeroIndex + 1000) mod n] + input2[(zeroIndex + 2000) mod n] + input2[(zeroIndex + 3000) mod n]

let test = readFile("day20-test.txt")
assert solvePart1(test) == 3
assert solvePart2(test) == 1623178306'i64

let input = readFile("day20-input.txt")
echo solvePart1(input)
echo solvePart2(input)