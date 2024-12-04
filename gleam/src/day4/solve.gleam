import adglent.{First, Second}
import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/option
import gleam/string

type Puzzle {
  Puzzle(parsed: dict.Dict(#(Int, Int), String), width: Int, height: Int)
}

type Dir {
  Up
  Down
  Left
  Right
  DownLeft
  DownRight
  UpLeft
  UpRight
}

fn get_size(input: String) -> #(Int, Int) {
  let lines =
    input
    |> string.split("\n")
  let assert Ok(first) = lines |> list.first
  #(first |> string.length, lines |> list.length)
}

fn parse(input: String) -> Puzzle {
  let #(width, height) = input |> get_size
  let parsed =
    input
    |> string.split("\n")
    |> list.index_fold(dict.new(), fn(outer_acc, line, y) {
      line
      |> string.split("")
      |> list.index_fold(dict.new(), fn(inner_acc, char, x) {
        inner_acc |> dict.insert(#(x, y), char)
      })
      |> dict.merge(outer_acc)
    })
  Puzzle(parsed:, width:, height:)
}

fn check_seq(seq: List(#(Int, Int)), puzzle: Puzzle) -> Bool {
  let check_letters = fn(letters: List(String)) -> Bool {
    case letters {
      ["X", "M", "A", "S"] -> True
      _ -> False
    }
  }
  seq
  |> list.map(fn(coord) {
    let assert Ok(letter) = puzzle.parsed |> dict.get(coord)
    letter
  })
  |> check_letters
}

fn get_seq_for_dir(start: #(Int, Int), dir: Dir) -> List(#(Int, Int)) {
  let #(x, y) = start
  case dir {
    Up -> list.repeat(x, 4) |> list.zip(list.range(y, y - 3))
    UpRight -> list.range(x, x + 3) |> list.zip(list.range(y, y - 3))
    Right -> list.range(x, x + 3) |> list.zip(list.repeat(y, 4))
    DownRight -> list.range(x, x + 3) |> list.zip(list.range(y, y + 3))
    Down -> list.repeat(x, 4) |> list.zip(list.range(y, y + 3))
    DownLeft -> list.range(x, x - 3) |> list.zip(list.range(y, y + 3))
    Left -> list.range(x, x - 3) |> list.zip(list.repeat(y, 4))
    UpLeft -> list.range(x, x - 3) |> list.zip(list.range(y, y - 3))
  }
}

fn get_valid_seqs(
  seqs: List(List(#(Int, Int))),
  puzzle: Puzzle,
) -> List(List(#(Int, Int))) {
  seqs |> list.filter(fn(seq) { check_seq(seq, puzzle) })
}

fn solve1(puzzle: Puzzle) {
  puzzle.parsed
  |> dict.filter(fn(_, val) { val == "X" })
  |> dict.keys
  |> list.map(fn(curr) {
    case curr {
      // Handle top left corner
      #(x, y) if x < 3 && y < 3 -> [Right, DownRight, Down]
      // Handle top right corner
      #(x, y) if x > puzzle.width - 4 && y < 3 -> [Down, DownLeft, Left]
      // Handle bottom left corner
      #(x, y) if x < 3 && y > puzzle.height - 4 -> [Up, UpRight, Right]
      // Handle bottom right corner
      #(x, y) if x > puzzle.width - 4 && y > puzzle.height - 4 -> [
        Left,
        UpLeft,
        Up,
      ]
      // Handle left side
      #(x, _) if x < 3 -> [Up, UpRight, Right, DownRight, Down]
      // Handle top side
      #(_, y) if y < 3 -> [Right, DownRight, Down, DownLeft, Left]
      // Handle right side
      #(x, _) if x > puzzle.width - 4 -> [Down, DownLeft, Left, UpLeft, Up]
      // Handle bottom side
      #(_, y) if y > puzzle.height - 4 -> [Left, UpLeft, Up, UpRight, Right]
      // Handle middle
      _ -> [Up, UpRight, Right, DownRight, Down, DownLeft, Left, UpLeft]
    }
    |> list.map(fn(dir) { get_seq_for_dir(curr, dir) })
    |> get_valid_seqs(puzzle)
  })
  |> list.flatten
  |> list.length
}

pub fn part1(input: String) {
  input |> parse |> solve1 |> int.to_string
}

fn get_x_coords(start: #(Int, Int)) {
  let #(x, y) = start
  let a = [#(x - 1, y - 1), start, #(x + 1, y + 1)]
  let b = [#(x - 1, y + 1), start, #(x + 1, y - 1)]

  [a, b]
}

fn check_seq2(seq: List(#(Int, Int)), puzzle: Puzzle) -> Bool {
  let check_letters = fn(letters: List(String)) -> Bool {
    case letters {
      ["M", "A", "S"] | ["S", "A", "M"] -> True
      _ -> False
    }
  }
  seq
  |> list.map(fn(coord) {
    let assert Ok(letter) = puzzle.parsed |> dict.get(coord)
    letter
  })
  |> check_letters
}

fn solve2(puzzle: Puzzle) {
  puzzle.parsed
  |> dict.filter(fn(_, val) { val == "A" })
  |> dict.keys
  |> list.map(fn(curr) {
    case curr {
      // Handle top left corner
      #(x, y)
        if x > 0 && x < puzzle.width - 1 && y > 0 && y < puzzle.height - 1
      ->
        get_x_coords(curr)
        |> list.all(fn(seq) { check_seq2(seq, puzzle) })
        |> option.Some
      _ -> option.None
    }
    |> option.unwrap(False)
  })
  |> list.filter(fn(b) { b })
  |> list.length
}

pub fn part2(input: String) {
  input |> parse |> solve2 |> int.to_string
}

pub fn main() {
  let assert Ok(part) = adglent.get_part()
  let assert Ok(input) = adglent.get_input("4")
  case part {
    First ->
      part1(input)
      |> adglent.inspect
      |> io.println
    Second ->
      part2(input)
      |> adglent.inspect
      |> io.println
  }
}
