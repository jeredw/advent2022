type Action = enum Rock = 0, Paper = 1, Scissors = 2
type EncryptedAction = enum X, Y, Z
type Turn = tuple[move: Action, reply: EncryptedAction]

proc readStrategy(filename: string): seq[Turn] =
  result = @[]
  for line in filename.lines:
    let move = case line[0]:
      of 'A': Rock
      of 'B': Paper
      of 'C': Scissors
      else: raise
    let reply = case line[2]:
      of 'X': X
      of 'Y': Y
      of 'Z': Z
      else: raise
    result.add((move, reply))

# ReplyEncoding is what an encrypted action means given each possible preceeding move
# For example, X=[Rock, Paper, Scissors] means X matches the opponent move
type ReplyEncoding = array[3, Action]

proc score(game: seq[Turn], x, y, z: ReplyEncoding): int =
  result = 0
  for (move, encryptedReply) in game:
    let reply = case encryptedReply
      of X: x[ord(move)]
      of Y: y[ord(move)]
      of Z: z[ord(move)]
    let score = case reply
      of Rock:     1 + (if move == reply: 3 elif move == Scissors: 6 else: 0)
      of Paper:    2 + (if move == reply: 3 elif move == Rock:     6 else: 0)
      of Scissors: 3 + (if move == reply: 3 elif move == Paper:    6 else: 0)
    result += score

proc solvePart1(game: seq[Turn]): int =
  let
    rock = [Rock, Rock, Rock]
    paper = [Paper, Paper, Paper]
    scissors = [Scissors, Scissors, Scissors]
  result = score(game, rock, paper, scissors)

proc solvePart2(game: seq[Turn]): int =
  let
    draw = [Rock, Paper, Scissors]
    lose = [Scissors, Rock, Paper]
    win = [Paper, Scissors, Rock]
  result = score(game, lose, draw, win)

let testStrategy = readStrategy("day2-test.txt")
assert solvePart1(testStrategy) == 15
assert solvePart2(testStrategy) == 12

let strategy = readStrategy("day2-input.txt")
echo(solvePart1(strategy))
echo(solvePart2(strategy))