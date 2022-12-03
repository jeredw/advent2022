import std/sets

type Rucksack = string

proc readRucksacks(filename: string): seq[Rucksack] =
  result = @[]
  for stuff in filename.lines:
    result.add(stuff)

proc findItemInBothCompartments(r: Rucksack): char =
  let
    xs = toHashSet(r[0 ..< len(r) div 2])
    ys = toHashSet(r[len(r) div 2 .. ^1])
  var common = xs * ys
  return pop(common)

proc findItemInAllThreeRucksacks(x, y, z: Rucksack): char =
  let
    xs = toHashSet(x)
    ys = toHashSet(y)
    zs = toHashSet(z)
  var common = xs * ys * zs
  return pop(common)

proc priority(item: char): int =
  result = case item
  of 'a'..'z': 1 + ord(item) - ord('a')
  of 'A'..'Z': 27 + ord(item) - ord('A')
  else: raise

proc solvePart1(sacks: seq[Rucksack]): int =
  result = 0
  for r in sacks:
    let commonItem = findItemInBothCompartments(r)
    result += priority(commonItem)

proc solvePart2(sacks: seq[Rucksack]): int =
  for i in 0 ..< len(sacks) div 3:
    let
      j = i * 3
      commonItem = findItemInAllThreeRucksacks(sacks[j], sacks[j + 1], sacks[j + 2])
    result += priority(commonItem)

let testSacks = readRucksacks("day3-test.txt")
assert solvePart1(testSacks) == 157
assert solvePart2(testSacks) == 70

let sacks = readRucksacks("day3-input.txt")
echo solvePart1(sacks)
echo solvePart2(sacks)