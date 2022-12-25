import std/tables
import std/math

proc weight(ch: char): int =
  case ch
  of '=': -2
  of '-': -1
  of '0': 0
  of '1': 1
  of '2': 2
  else: raise

proc readSnafu(s: string): int64 =
  result = 0
  for i in 0 .. len(s) - 1:
    let ch = s[len(s) - 1 - i]
    result += (5 ^ i) * weight(ch)

proc printSnafu(n: int64): string =
  var n = n
  result = ""
  while true:
    result.insert($"012=-"[n mod 5], 0)
    n = (n div 5) + @[0, 0, 0, 1, 1][n mod 5]
    if n == 0:
      break

proc test(n: int, s: string): void =
  assert readSnafu(s) == n
  assert printSnafu(n) == s

proc sum(filename: string): int64 =
  result = 0
  for line in filename.lines():
    result += readSnafu(line)

const tests = @[
  (1, "1"),
  (2, "2"),
  (3, "1="),
  (4, "1-"),
  (5, "10"),
  (6, "11"),
  (7, "12"),
  (8, "2="),
  (9, "2-"),
  (10, "20"),
  (15, "1=0"),
  (20, "1-0"),
  (2022, "1=11-2"),
  (12345, "1-0---0"),
  (314159265, "1121-1110-1=0"),
]
for (n, s) in tests:
  test(n, s)

assert sum("day25-test.txt") == 4890
echo printSnafu(sum("day25-input.txt"))
