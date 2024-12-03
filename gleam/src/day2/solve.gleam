import adglent.{First, Second}
import gleam/int
import gleam/io
import gleam/list
import gleam/option
import gleam/order
import gleam/pair
import gleam/result
import gleam/string

fn enumerate(l: List(a)) -> List(#(Int, a)) {
  l |> list.index_map(fn(v, i) { #(i, v) })
}

pub fn parse(input: String) {
  input |> string.split("\n") |> list.map(parse_line)
}

pub fn parse_line(input: String) {
  input
  |> string.split(" ")
  |> list.map(int.parse)
  |> result.partition
  |> pair.first
  |> list.reverse
}

fn map_to_ord_diff(val: #(Int, Int)) -> #(order.Order, Int) {
  let #(left, right) = val
  let diff = int.absolute_value(right - left)
  let ord = int.compare(right, left)
  #(ord, diff)
}

fn if_false(b: Bool, default: a, cb: fn() -> a) -> a {
  case b {
    True -> default
    False -> cb()
  }
}

fn if_some(opt: option.Option(a), default: b, cb: fn(a) -> b) -> b {
  case opt {
    option.None -> default
    option.Some(val) -> cb(val)
  }
}

fn fold_ord_diff(
  acc: option.Option(#(order.Order, Int)),
  curr: #(order.Order, Int),
) -> list.ContinueOrStop(option.Option(#(order.Order, Int))) {
  let #(ord, diff) = curr
  use val <- if_some(acc, list.Continue(option.Some(curr)))
  use <- if_false(diff < 1 || diff > 3, list.Stop(option.None))
  let #(val_ord, val_diff) = val
  case ord == val_ord {
    True if val_diff > 0 && val_diff < 4 -> list.Continue(option.Some(curr))
    _ -> list.Stop(option.None)
  }
}

pub fn test_report(input: List(Int)) {
  input
  |> list.window_by_2
  |> list.map(map_to_ord_diff)
  |> list.fold_until(option.None, fold_ord_diff)
  |> option.is_some
}

pub fn part1(input: String) {
  input
  |> parse
  |> list.map(test_report)
  |> list.count(fn(valid) { valid })
  |> int.to_string
}

pub fn test_report2(input: List(Int)) -> Bool {
  let enumerated = input |> enumerate
  let range = list.range(0, input |> list.length |> int.subtract(1))
  range
  |> list.find(fn(i) {
    enumerated
    |> list.filter_map(fn(val) {
      case val {
        #(idx, _) if idx == i -> Error(Nil)
        #(_, val) -> Ok(val)
      }
    })
    |> test_report
  })
  |> option.from_result
  |> option.is_some
}

pub fn part2(input: String) {
  input
  |> parse
  |> list.map(test_report2)
  |> list.count(fn(valid) { valid })
  |> int.to_string
}

pub fn main() {
  let assert Ok(part) = adglent.get_part()
  let assert Ok(input) = adglent.get_input("2")
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
