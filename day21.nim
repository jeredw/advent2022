import std/strscans
import std/strutils
import std/tables

type
  NodeKind = enum
    nkExpression,
    nkNumber
  MonkeySay = ref object
    case kind: NodeKind
    of nkExpression: expression: tuple[a: string, op: char, b: string]
    of nkNumber: number: int64
  Script = Table[string, MonkeySay]

proc readScript(filename: string): Script =
  result = initTable[string, MonkeySay]()
  for line in filename.lines():
    var name, a, b: string
    var op: char
    if scanf(line, "$+: $+ $c $+", name, a, op, b):
      result[name] = MonkeySay(kind: nkExpression, expression: (a, op, b))
    else:
      var number: int
      assert scanf(line, "$+: $i", name, number)
      result[name] = MonkeySay(kind: nkNumber, number: number)

proc evaluate(name: string, script: Script): int64 =
  let say = script[name]
  case say.kind
  of nkNumber:
    return say.number
  of nkExpression:
    let
      a = evaluate(say.expression.a, script)
      b = evaluate(say.expression.b, script)
    case say.expression.op
    of '+': return a + b
    of '-': return a - b
    of '/': return a div b
    of '*': return a * b
    else: raise

proc solvePart1(script: Script): int64 =
  return evaluate("root", script)

proc dependsOnMonkey(start, target: string, script: Script): bool =
  if start == target:
    return true
  let say = script[start]
  if say.kind == nkExpression:
    return dependsOnMonkey(say.expression.a, target, script) or dependsOnMonkey(say.expression.b, target, script)
  return false

const unknownName = "humn"

proc solve(name: string, script: Script, mustEqual: int64 = 0): int64 =
  if name == unknownName:
    return mustEqual
  let say = script[name]
  assert say.kind == nkExpression
  let
    a = say.expression.a
    b = say.expression.b
    aIsUnknown = dependsOnMonkey(a, unknownName, script)
    bIsUnknown = dependsOnMonkey(b, unknownName, script)
  assert aIsUnknown != bIsUnknown
  let
    (knownExpression, unknownExpression) = if aIsUnknown: (b, a) else: (a, b)
    knownValue = evaluate(knownExpression, script)
  if name == "root":
    return solve(unknownExpression, script, knownValue)
  let subMustEqual =
    case say.expression.op
    # mustEqual = x + knownValue or mustEqual = knownValue + x
    of '+': mustEqual - knownValue
    # mustEqual = x - knownValue -> x = mustEqual + knownValue
    # mustEqual = knownValue - x -> x = knownValue - mustEqual
    of '-': (if aIsUnknown: mustEqual + knownValue else: knownValue - mustEqual)
    # mustEqual = x * knownValue or mustEqual = knownValue * x
    of '*': mustEqual div knownValue
    # mustEqual = x / knownValue -> x = mustEqual * knownValue
    # mustEqual = knownValue / x -> x = knownValue / mustEqual
    of '/': (if aIsUnknown: mustEqual * knownValue else: knownValue div mustEqual)
    else: raise
  return solve(unknownExpression, script, subMustEqual)

proc solvePart2(script: Script): int64 =
  return solve("root", script)

proc checkPart2(script: Script): bool =
  let check = solvePart2(script)
  var script2 = script
  script2[unknownName] = MonkeySay(kind: nkNumber, number: check)
  return evaluate(script2["root"].expression.a, script2) == evaluate(script2["root"].expression.b, script2)

let test = readScript("day21-test.txt")
assert solvePart1(test) == 152'i64
assert solvePart2(test) == 301'i64

let test2 = readScript("day21-test2.txt")
assert solvePart2(test2) == 1

let input = readScript("day21-input.txt")
echo solvePart1(input)
echo solvePart2(input)
assert checkPart2(input)