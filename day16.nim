import std/sequtils
import std/strscans
import std/strutils
import std/sugar
import std/sets
import std/tables

type Vertex = ref object
  name: string
  flow: int
  edges: seq[string]
type Graph = ref object
  vertices: Table[string, Vertex]
  distance: Table[(string, string), int]

const infinity = 1000000

proc computeShortestPaths(g: Graph): void =
  g.distance = initTable[(string, string), int]()
  var vs = toSeq(values(g.vertices)).map(x => x.name)
  for u in vs:
    for v in vs:
      g.distance[(u, v)] = infinity
  for u in vs:
    for v in g.vertices[u].edges:
      g.distance[(u, v)] = 1
      g.distance[(v, u)] = 1
  for v in vs:
    g.distance[(v, v)] = 0
  for k in vs:
    for i in vs:
      for j in vs:
        if g.distance[(i, j)] > g.distance[(i, k)] + g.distance[(k, j)]:
          g.distance[(i, j)] = g.distance[(i, k)] + g.distance[(k, j)]

proc readGraph(filename: string): Graph =
  result = Graph(vertices: initTable[string, Vertex]())
  for line in filename.lines():
    var v = Vertex(edges: @[])
    var edgeList, skip: string
    assert scanf(line, "Valve $+ has flow rate=$i; $+ $+ to $+ $+", v.name, v.flow, skip, skip, skip, edgeList)
    v.edges = edgeList.split(", ").toSeq()
    result.vertices[v.name] = v
  computeShortestPaths(result)

proc printGraph(g: Graph): void =
  for v in values(g.vertices):
    echo v.name, " (", v.flow, "): ", v.edges

type SearchState = object
  humanPos: string
  humanGoal: string
  humanArrivalTime: int
  elephantPos: string
  elephantGoal: string
  elephantArrivalTime: int
  open: HashSet[string]
  timeLeft: int
  flowRate: int
  flowBefore: int

# i think this problem should admit a nice dynamic programming solution,
# since the input has just 15 vertices with flow.  so a table of size
# (2^15) * 26 * 16 * 16 should suffice - indexed on open set, time left,
# human position and elephant position (including the start position).
# but this stupid search finished before i finished coding that.
proc plan(g: Graph, state: SearchState): int =
  if state.timeLeft == 0: return state.flowBefore
  var state = state
  if state.humanGoal != "" and state.timeLeft == state.humanArrivalTime:
    let v = state.humanGoal
    state.humanPos = v
    state.humanGoal = ""
    assert not state.open.contains(v)
    state.open.incl(v)
    state.flowRate += g.vertices[v].flow
  if state.elephantGoal != "" and state.timeLeft == state.elephantArrivalTime:
    let v = state.elephantGoal
    state.elephantPos = v
    state.elephantGoal = ""
    assert not state.open.contains(v)
    state.open.incl(v)
    state.flowRate += g.vertices[v].flow
  var humanGoals: seq[(int, string)] = @[]
  if state.humanGoal == "":
    for v in g.vertices.keys():
      if state.humanPos == v or state.open.contains(v) or g.vertices[v].flow == 0:
        continue
      if state.elephantPos != "" and state.elephantGoal == v:
        continue
      let dist = g.distance[(state.humanPos, v)]
      if state.timeLeft > dist + 1:
        humanGoals.add((state.timeLeft - (dist + 1), v))
  var elephantGoals: seq[(int, string)] = @[]
  if state.elephantPos != "" and state.elephantGoal == "":
    for v in g.vertices.keys():
      if state.elephantPos == v or state.open.contains(v) or g.vertices[v].flow == 0:
        continue
      if state.humanGoal == v:
        continue
      let dist = g.distance[(state.elephantPos, v)]
      if state.timeLeft > dist + 1:
        elephantGoals.add((state.timeLeft - (dist + 1), v))
  if len(humanGoals) == 0 and len(elephantGoals) == 0:
    state.timeLeft -= 1
    state.flowBefore += state.flowRate
    return plan(g, state)
  result = state.flowBefore + state.flowRate * state.timeLeft
  if len(humanGoals) > 0 and len(elephantGoals) > 0:
    for (humanArrivalTime, humanGoal) in humanGoals:
      for (elephantArrivalTime, elephantGoal) in elephantGoals:
        if humanGoal != elephantGoal:
          var newState = state
          newState.humanGoal = humanGoal
          newState.humanArrivalTime = humanArrivalTime
          newState.elephantGoal = elephantGoal
          newState.elephantArrivalTime = elephantArrivalTime
          newState.timeLeft -= 1
          newState.flowBefore += state.flowRate
          result = max(result, plan(g, newState))
        elif humanArrivalTime <= elephantArrivalTime:
          var newState = state
          newState.humanGoal = humanGoal
          newState.humanArrivalTime = humanArrivalTime
          newState.timeLeft -= 1
          newState.flowBefore += state.flowRate
          result = max(result, plan(g, newState))
        else:
          var newState = state
          newState.elephantGoal = elephantGoal
          newState.elephantArrivalTime = elephantArrivalTime
          newState.timeLeft -= 1
          newState.flowBefore += state.flowRate
          result = max(result, plan(g, newState))
  elif len(humanGoals) > 0:
    for (humanArrivalTime, humanGoal) in humanGoals:
      var newState = state
      newState.humanGoal = humanGoal
      newState.humanArrivalTime = humanArrivalTime
      newState.timeLeft -= 1
      newState.flowBefore += state.flowRate
      result = max(result, plan(g, newState))
  elif len(elephantGoals) > 0:
    for (elephantArrivalTime, elephantGoal) in elephantGoals:
      var newState = state
      newState.elephantGoal = elephantGoal
      newState.elephantArrivalTime = elephantArrivalTime
      newState.timeLeft -= 1
      newState.flowBefore += state.flowRate
      result = max(result, plan(g, newState))

proc solvePart1(g: Graph): int =
  var state = SearchState(humanPos: "AA", open: initHashSet[string](), timeLeft: 30, flowRate: 0, flowBefore: 0)
  plan(g, state)

proc solvePart2(g: Graph): int =
  var state = SearchState(humanPos: "AA", elephantPos: "AA", open: initHashSet[string](), timeLeft: 26, flowRate: 0, flowBefore: 0)
  plan(g, state)

let test = readGraph("day16-test.txt")
assert solvePart1(test) == 1651
assert solvePart2(test) == 1707

let input = readGraph("day16-input.txt")
echo solvePart1(input)
echo solvePart2(input)