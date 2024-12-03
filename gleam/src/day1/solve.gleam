import adglent.{First, Second}
import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/option
import gleam/pair
import gleam/regex
import gleam/string

fn parse_input(input: String) -> #(List(Int), List(Int)) {
  input
  |> string.split("\n")
  |> list.map(parse_line)
  |> list.unzip
}

fn sort_lists(input: #(List(Int), List(Int))) -> #(List(Int), List(Int)) {
  let #(left_list, right_list) = input
  #(
    left_list |> list.sort(by: int.compare),
    right_list |> list.sort(by: int.compare),
  )
}

fn compare_lists(lists: #(List(Int), List(Int))) -> List(Int) {
  let #(left_list, right_list) = lists
  list.zip(left_list, right_list)
  |> list.map(fn(tuple) {
    let #(left, right) = tuple
    left - right |> int.absolute_value
  })
}

fn parse_line(line: String) -> #(Int, Int) {
  let assert Ok(rgx) = regex.from_string("(\\d+)\\s+(\\d+)")
  let assert [regex.Match(_, [option.Some(left_str), option.Some(right_str)])] =
    rgx |> regex.scan(line)
  let assert Ok(left) = left_str |> int.parse
  let assert Ok(right) = right_str |> int.parse
  #(left, right)
}

pub fn part1(input: String) {
  input
  |> parse_input
  |> sort_lists
  |> compare_lists
  |> list.fold(0, int.add)
  |> int.to_string
}

fn get_counts(input: #(List(Int), List(Int))) -> #(List(Int), List(Int)) {
  let #(left_list, right_list) = input
  let lookup =
    left_list
    |> list.fold(dict.new(), fn(acc, curr) {
      case acc |> dict.get(curr) {
        Ok(_) -> acc
        Error(_) -> {
          let val = curr |> get_count(right_list)
          acc |> dict.insert(curr, val)
        }
      }
    })
  let right_list =
    left_list
    |> list.map(fn(val) {
      let assert Ok(mult) = lookup |> dict.get(val)
      val * mult
    })
  #(left_list, right_list)
}

fn get_count(needle: Int, haystack: List(Int)) -> Int {
  haystack |> list.count(fn(val) { val == needle })
}

pub fn part2(input: String) {
  input
  |> parse_input
  |> get_counts
  |> pair.second
  |> list.fold(0, int.add)
  |> int.to_string
}

pub fn main() {
  let assert Ok(part) = adglent.get_part()
  let assert Ok(input) = adglent.get_input("1")
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
