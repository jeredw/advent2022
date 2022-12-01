import std/sequtils
import std/strutils
import std/algorithm

# readFoodInventory returns a total of calories carried by each elf
proc readFoodInventory(filename: string): seq[int] =
  result = @[];
  var totalCalories = 0
  for line in filename.lines:
    if line.isEmptyOrWhitespace():
      # empty lines delimit each elf
      result.add(totalCalories)
      totalCalories = 0
      continue
    let calories = parseInt(line.strip())
    totalCalories += calories
  # last elf has no following empty line
  result.add(totalCalories)

# solvePart1 finds the elf with the most calories
proc solvePart1(inventory: seq[int]): int =
  result = max(inventory)

# solvePart2 sums the top 3 elfs by calories
proc solvePart2(inventory: seq[int]): int =
  let top = sorted(inventory, cmp, Descending)  # missing partial sort?
  result = top[0] + top[1] + top[2]

let testInventory = readFoodInventory("day1-test.txt")
assert solvePart1(testInventory) == 24000
assert solvePart2(testInventory) == 45000

let inventory = readFoodInventory("day1-input.txt")
echo(solvePart1(inventory));
echo(solvePart2(inventory));