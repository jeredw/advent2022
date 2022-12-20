import std/strscans
import std/tables

type Blueprint = ref object
  id: int
  ore: int # ore
  clay: int # ore
  obsidian: tuple[ore: int, clay: int]
  geode: tuple[ore: int, obsidian: int]

proc readBlueprints(filename: string): seq[Blueprint] =
  result = @[]
  for line in filename.lines():
    var blueprint = Blueprint()
    assert scanf(line, "Blueprint $i: Each ore robot costs $i ore. Each clay robot costs $i ore. Each obsidian robot costs $i ore and $i clay. Each geode robot costs $i ore and $i obsidian.", blueprint.id, blueprint.ore, blueprint.clay, blueprint.obsidian.ore, blueprint.obsidian.clay, blueprint.geode.ore, blueprint.geode.obsidian)
    result.add(blueprint)

type State = object
  resources: tuple[ore: int, clay: int, obsidian: int, geode: int]
  robots: tuple[ore: int, clay: int, obsidian: int, geode: int]
  time: int

proc build(state: State): State =
  result = state
  result.resources.ore += state.robots.ore
  result.resources.clay += state.robots.clay
  result.resources.obsidian += state.robots.obsidian
  result.resources.geode += state.robots.geode
  result.time -= 1

proc search(bp: Blueprint, state: State, best: var seq[int]): int =
  result = state.resources.geode
  if state.time == 0:
    return result
  # best first heuristic is needed for reasonable runtime
  if state.resources.geode < best[state.time]:
    return best[state.time]
  best[state.time] = max(best[state.time], state.resources.geode)
  let maxOre = max(max(max(bp.ore, bp.clay), bp.obsidian.ore), bp.geode.ore)
  let tooMuchOre = state.resources.ore div maxOre > state.time
  let oreRobotsMaxedOut = state.robots.ore >= maxOre
  let tooMuchClay = state.resources.clay div bp.obsidian.clay > state.time
  let tooMuchObsidian = state.resources.obsidian div bp.geode.obsidian > state.time
  var state = state
  if state.resources.ore >= bp.geode.ore and state.resources.obsidian >= bp.geode.obsidian:
    var newState = build(state)
    newState.resources.ore -= bp.geode.ore
    newState.resources.obsidian -= bp.geode.obsidian
    newState.robots.geode += 1
    return search(bp, newState, best)
  if state.time > 4 and not oreRobotsMaxedOut and not tooMuchOre and state.resources.ore >= bp.ore:
    var newState = build(state)
    newState.resources.ore -= bp.ore
    newState.robots.ore += 1
    result = max(result, search(bp, newState, best))
  if state.time > 3 and not tooMuchClay and state.resources.ore >= bp.clay:
    var newState = build(state)
    newState.resources.ore -= bp.clay
    newState.robots.clay += 1
    result = max(result, search(bp, newState, best))
  if state.time > 2 and not tooMuchObsidian and state.resources.ore >= bp.obsidian.ore and state.resources.clay >= bp.obsidian.clay:
    var newState = build(state)
    newState.resources.ore -= bp.obsidian.ore
    newState.resources.clay -= bp.obsidian.clay
    newState.robots.obsidian += 1
    result = max(result, search(bp, newState, best))
  result = max(result, search(bp, build(state), best))

proc findMostGeodes(bp: Blueprint, time: int): int =
  var best = newSeq[int](time + 1)
  return search(bp, State(time: time, robots: (1, 0, 0, 0)), best)

proc solvePart1(input: seq[Blueprint]): int =
  result = 0
  for bp in input:
    result += findMostGeodes(bp, 24) * bp.id

proc solvePart2(input: seq[Blueprint]): int =
  result = 1
  for bp in input[0 .. 2]:
    result *= findMostGeodes(bp, 32)

let test = readBlueprints("day19-test.txt")
assert findMostGeodes(test[0], 24) == 9
assert findMostGeodes(test[1], 24) == 12
#echo findMostGeodes(test[0], 32)
#assert findMostGeodes(test[0], 32) == 56
assert findMostGeodes(test[1], 32) == 62

let input = readBlueprints("day19-input.txt")
echo(solvePart1(input))
echo(solvePart2(input))
