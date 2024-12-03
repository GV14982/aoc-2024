import adglent.{First, Second}
import gleam/int
import gleam/io
import gleam/list
import gleam/option
import gleam/pair
import gleam/regexp
import gleam/result

fn handle_submatches(submatches: List(option.Option(String))) -> Int {
  let assert [option.Some(left), option.Some(right)] =
    submatches
    |> list.map(fn(opt) {
      opt
      |> option.map(int.parse)
      |> option.map(option.from_result)
      |> option.flatten
    })
  left * right
}

fn handle_match(match: regexp.Match) {
  match.submatches |> handle_submatches
}

fn parse(input: String) {
  let assert Ok(regex) = regexp.from_string("mul\\((\\d{1,3}),(\\d{1,3})\\)")
  regex
  |> regexp.scan(input)
  |> list.map(handle_match)
  |> list.fold(0, int.add)
}

pub fn part1(input: String) {
  input |> parse |> int.to_string
}

fn fold_match(acc: #(List(Int), Bool), curr: regexp.Match) {
  let #(products, should_process) = acc
  case curr.content, should_process {
    "do()", _ -> #(products, True)
    "don't()", _ -> #(products, False)
    _, True -> {
      let assert Ok(product) =
        curr.submatches
        |> list.rest
        |> result.map(handle_submatches)
      #([product, ..products], should_process)
    }
    _, False -> acc
  }
}

fn parse2(input: String) {
  let assert Ok(regex) =
    regexp.from_string("(mul\\((\\d{1,3}),(\\d{1,3})\\)|don't\\(\\)|do\\(\\))")
  regex
  |> regexp.scan(input)
  |> list.fold(#([], True), fold_match)
  |> pair.first
  |> list.fold(0, int.add)
}

pub fn part2(input: String) {
  input |> parse2 |> int.to_string
}

pub fn main() {
  let assert Ok(part) = adglent.get_part()
  let assert Ok(input) = adglent.get_input("3")
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
