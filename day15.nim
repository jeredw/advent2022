import std/algorithm
import std/sets
import std/sequtils
import std/strscans
import std/sugar
import std/random

type Point = tuple[x: int, y: int]
type Sensor = ref object
  position: Point
  closestBeacon: Point
  range: int
type Interval = tuple[left: int, right: int]

const infinity = 100000000

proc distance(a, b: Point): int =
  abs(a.x - b.x) + abs(a.y - b.y)

proc readSensors(filename: string): seq[Sensor] =
  result = @[]
  for line in filename.lines():
    var sensor = Sensor()
    assert scanf(line, "Sensor at x=$i, y=$i: closest beacon is at x=$i, y=$i", sensor.position.x, sensor.position.y, sensor.closestBeacon.x, sensor.closestBeacon.y)
    sensor.range = distance(sensor.position, sensor.closestBeacon)
    result.add(sensor)

proc rowCoverageForOneSensor(sensor: Sensor, y: int): Interval =
  let rowDistance = abs(sensor.position.y - y)
  if rowDistance > sensor.range:
    return (0, -1)
  return (sensor.position.x - (sensor.range - rowDistance), sensor.position.x + (sensor.range - rowDistance))

proc rowCoverage(sensors: seq[Sensor], y: int): int =
  let xs = sensors.map(s => rowCoverageForOneSensor(s, y))
  var rightmost = -infinity
  result = 0
  for (left, right) in sorted(xs):
    if right < left:  # skip empty intervals
      continue
    if left > rightmost:
      result += right - left + 1
      rightmost = right
    elif right > rightmost:
      result += right - rightmost  # already counted rightmost
      rightmost = right
  var beaconsInRow = initHashSet[int]()
  for s in sensors:
    if s.closestBeacon.y == y:
      beaconsInRow.incl(s.closestBeacon.x)
  result -= len(beaconsInRow)

# this takes 3.8s on my 2021 macbook pro so is fast enough
# but it feels like there should be a better algorithm
proc findMissingBeaconSlowly(sensors: seq[Sensor], range: int): int64 =
  for y in 0 .. range:
    let xs = sensors.map(s => rowCoverageForOneSensor(s, y))
    var rightmost = -1
    for (left, right) in sorted(xs):
      if right < left:  # skip empty intervals
        continue
      if left > rightmost:
        if rightmost >= 0 and left > rightmost + 1:
          return cast[int64](rightmost + 1) * 4000000 + cast[int64](y)
        rightmost = right
      elif right > rightmost:
        rightmost = right

let test = readSensors("day15-test.txt")
assert rowCoverage(test, 10) == 26
assert findMissingBeaconSlowly(test, range = 20) == 56000011

let input = readSensors("day15-input.txt")
echo rowCoverage(input, 2000000)
echo findMissingBeaconSlowly(input, range = 4000000)
