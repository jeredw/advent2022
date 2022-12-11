import std/strscans
import std/strutils
import std/sequtils
import std/algorithm

type Monkey = ref object
  id: int
  items: seq[int]
  operation: char
  argument: string
  testDivisor: int
  ifTrueMonkey: int
  ifFalseMonkey: int

proc readOneMonkey(file: File): Monkey =
  result = Monkey(items: @[])
  assert scanf(file.readLine(), "Monkey $i", result.id)
  var items: string
  assert scanf(file.readLine(), "  Starting items: $+", items)
  result.items = items.split(", ").map(parseInt)
  assert scanf(file.readLine(), "  Operation: new = old $c $+", result.operation, result.argument)
  assert scanf(file.readLine(), "  Test: divisible by $i", result.testDivisor)
  assert scanf(file.readLine(), "    If true: throw to monkey $i", result.ifTrueMonkey)
  assert scanf(file.readLine(), "    If false: throw to monkey $i", result.ifFalseMonkey)

proc readMonkeys(filename: string): seq[Monkey] =
  result = @[]
  let file = open(filename)
  defer: file.close()
  while true:
    result.add(readOneMonkey(file))
    assert result[^1].id == len(result) - 1
    if file.endOfFile():
      return
    assert file.readLine().isEmptyOrWhitespace()

proc play(inputMonkeys: seq[Monkey], numRounds: int, relief: bool): int64 =
  let monkeys = deepCopy(inputMonkeys)
  var base = 1
  for monkey in monkeys:
    base *= monkey.testDivisor
  var active = newSeq[int64](len(monkeys))
  for i in 1 .. numRounds:
    for monkey in monkeys:
      active[monkey.id] += len(monkey.items)
      for item in monkey.items:
        let argument = if monkey.argument == "old": item else: parseInt(monkey.argument)
        let worried = case monkey.operation
        of '+': (item + argument) mod base
        of '*': (item * argument) mod base
        else: raise
        let bored = if relief: worried div 3 else: worried
        let passTo = if bored mod monkey.testDivisor == 0: monkey.ifTrueMonkey else: monkey.ifFalseMonkey
        monkeys[passTo].items.add(bored)
      monkey.items = @[]
  active.sort()
  return active[^1] * active[^2]

let test = readMonkeys("day11-test.txt")
assert play(test, numRounds = 20, relief = true) == 10605
assert play(test, numRounds = 10000, relief = false) == 2713310158'i64

let input = readMonkeys("day11-input.txt")
echo play(input, numRounds = 20, relief = true)
echo play(input, numRounds = 10000, relief = false)