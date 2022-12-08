import std/strutils

type File = ref object
  name: string
  size: int

type Directory = ref object
  name: string
  parent: Directory
  subdirs: seq[Directory]
  size: int
  files: seq[File]

proc computeDirectorySize(dir: Directory): void =
  dir.size = 0
  for file in dir.files:
    dir.size += file.size
  for subdir in dir.subdirs:
    computeDirectorySize(subdir)
    dir.size += subdir.size

proc readDirectory(filename: string): Directory =
  let root = Directory(name: "/", parent: nil, subdirs: @[], files: @[])
  var dir = root
  for line in filename.lines():
    if line[0] == '$':
      let command = line[2 .. 3]
      assert command == "cd" or command == "ls"
      if command == "cd":
        let path = line[5 .. ^1]
        case path
        of "/":
          dir = root
        of "..":
          dir = dir.parent
        else:
          let subdir = Directory(name: path, parent: dir, subdirs: @[], files: @[])
          dir.subdirs.add(subdir)
          dir = subdir
    else:  # listing
      let
        s = line.splitWhitespace()
        (size, name) = (s[0], s[1])
      if size != "dir":
        dir.files.add(File(name: name, size: parseInt(size)))
  computeDirectorySize(root)
  result = root

proc printDirectory(dir: Directory): void =
  if dir.parent != nil:
    echo "[", dir.parent.name, "/", dir.name, "]"
  else:
    echo "[", dir.name, "]"
  for file in dir.files:
    echo file.name, " ", file.size
  for subdir in dir.subdirs:
    printDirectory(subdir)

proc sumSmallDirectorySize(dir: Directory): int =
  result = 0
  if dir.size < 100000:
    result += dir.size
  for subdir in dir.subdirs:
    result += sumSmallDirectorySize(subdir)

proc findBestDirectory(dir: Directory, needed: int): int =
  if dir.size >= needed:
    var best = dir.size
    for subdir in dir.subdirs:
      let bestSubdir = findBestDirectory(subdir, needed)
      if bestSubdir > 0 and bestSubdir < best:
        best = bestSubdir
    return best
  return 0

proc solvePart1(dir: Directory): int =
  sumSmallDirectorySize(dir)

proc solvePart2(dir: Directory): int =
  let
    total = 70000000
    required = 30000000
    used = dir.size
    unused = total - used
    needed = required - unused
  return findBestDirectory(dir, needed)

let test = readDirectory("day7-test.txt")
assert solvePart1(test) == 95437
assert solvePart2(test) == 24933642

let input = readDirectory("day7-input.txt")
echo solvePart1(input)
echo solvePart2(input)