import std/sets
import std/strscans

type Point = tuple[x: int, y: int, z: int]
type CubeSet = HashSet[Point]

proc readCubes(filename: string): CubeSet =
  result = initHashSet[Point]()
  for line in filename.lines():
    var x, y, z: int
    assert scanf(line, "$i,$i,$i", x, y, z)
    result.incl((x, y, z))

const faceDirections = @[(-1, 0, 0), (1, 0, 0), (0, -1, 0), (0, 1, 0), (0, 0, -1), (0, 0, 1)]

proc countExposedFaces(cubes: CubeSet): int =
  result = 0
  for cube in cubes:
    for (dx, dy, dz) in faceDirections:
      if not cubes.contains((cube.x + dx, cube.y + dy, cube.z + dz)):
        result += 1

const infinity = 1000

proc fillSteam(cubes: CubeSet): CubeSet =
  result = initHashSet[Point]()
  var lower: Point = (infinity, infinity, infinity)
  var upper: Point = (0, 0, 0)
  for cube in cubes:
    lower.x = min(cube.x, lower.x)
    lower.y = min(cube.y, lower.y)
    lower.z = min(cube.z, lower.z)
    upper.x = max(cube.x, upper.x)
    upper.y = max(cube.y, upper.y)
    upper.z = max(cube.z, upper.z)
  lower = (lower.x - 2, lower.y - 2, lower.z - 2)
  upper = (upper.x + 2, upper.y + 2, upper.z + 2)
  var open = initHashSet[Point]()
  open.incl(lower)
  while len(open) > 0:
    let cube = open.pop()
    result.incl(cube)
    for (dx, dy, dz) in faceDirections:
      let n: Point = (cube.x + dx, cube.y + dy, cube.z + dz)
      if n.x < lower.x or n.y < lower.y or n.z < lower.z:
        continue
      if n.x > upper.x or n.y > upper.y or n.z > upper.z:
        continue
      if not cubes.contains(n) and not result.contains(n):
        open.incl(n)

proc countExposedFacesInSteam(cubes: CubeSet): int =
  result = 0
  let steam = fillSteam(cubes)
  for cube in cubes:
    for (dx, dy, dz) in faceDirections:
      let neighbor = (cube.x + dx, cube.y + dy, cube.z + dz)
      if not cubes.contains(neighbor) and steam.contains(neighbor):
        result += 1

let test = readCubes("day18-test.txt")
assert countExposedFaces(test) == 64
assert countExposedFacesInSteam(test) == 58

let input = readCubes("day18-input.txt")
echo countExposedFaces(input)
echo countExposedFacesInSteam(input)
