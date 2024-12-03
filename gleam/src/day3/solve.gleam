import adglent.{First, Second}
import gleam/int
import gleam/io
import gleam/list
import gleam/option
import gleam/pair
import gleam/regexp
import gleam/result
import gleam/string

type Operation {
  Mul(Int, Int)
  Do
  Dont
}

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

fn bespoke_parser(input: String, ops: List(Operation)) -> List(Operation) {
  case input {
    "mul(" <> tail -> {
      let #(opt_op, tail) = consume_mul(tail)
      let ops = case opt_op {
        option.Some(op) -> [op, ..ops]
        option.None -> ops
      }
      bespoke_parser(tail, ops)
    }
    "" -> ops
    input ->
      case string.pop_grapheme(input) {
        Ok(#(_, tail)) -> bespoke_parser(tail, ops)
        Error(_) -> ops
      }
  }
}

fn consume_mul(input: String) -> #(option.Option(Operation), String) {
  case input {
    input -> {
      case consume_num(input, ",", "") {
        #(option.Some(left), tail) ->
          case consume_num(tail, ")", "") {
            #(option.Some(right), tail) -> #(
              option.Some(Mul(left, right)),
              tail,
            )
            #(option.None, tail) -> #(option.None, tail)
          }
        #(option.None, tail) -> #(option.None, tail)
      }
    }
  }
}

fn consume_num(
  input: String,
  terminator: String,
  digits: String,
) -> #(option.Option(Int), String) {
  case string.pop_grapheme(input) {
    Ok(#(head, tail)) -> {
      case is_digit(head) {
        True -> consume_num(tail, terminator, digits <> head)
        False -> {
          case string.length(digits), head == terminator {
            len, True if len < 4 && len > 0 -> {
              let assert Ok(num) = digits |> int.parse
              #(option.Some(num), tail)
            }
            _, _ -> #(option.None, input)
          }
        }
      }
    }
    Error(_) -> #(option.None, input)
  }
}

fn is_digit(str: String) -> Bool {
  case str {
    "0" -> True
    str -> is_digit_start(str)
  }
}

fn is_digit_start(str: String) -> Bool {
  case str {
    "1" | "2" | "3" | "4" | "5" | "6" | "7" | "8" | "9" -> True
    _ -> False
  }
}

pub fn part1(input: String) {
  // input |> parse |> int.to_string
  input
  |> bespoke_parser([])
  |> list.fold(0, fn(acc, curr) {
    case curr {
      Mul(left, right) -> acc |> int.add(left * right)
      _ -> acc
    }
  })
  |> int.to_string
}

fn bespoke_parser2(input: String, ops: List(Operation)) -> List(Operation) {
  case input {
    "do()" <> tail -> bespoke_parser2(tail, [Do, ..ops])
    "don't()" <> tail -> bespoke_parser2(tail, [Dont, ..ops])
    "mul(" <> tail -> {
      let #(opt_op, tail) = consume_mul(tail)
      let ops = case opt_op {
        option.Some(op) -> [op, ..ops]
        option.None -> ops
      }
      bespoke_parser2(tail, ops)
    }
    "" -> ops
    input ->
      case string.pop_grapheme(input) {
        Ok(#(_, tail)) -> bespoke_parser2(tail, ops)
        Error(_) -> ops
      }
  }
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
  // input |> parse2 |> int.to_string
  input
  |> bespoke_parser2([])
  |> list.reverse
  |> list.fold(#(0, True), fn(acc, curr) {
    let #(val, should_process) = acc
    case curr {
      Do -> #(val, True)
      Dont -> #(val, False)
      Mul(_, _) if !should_process -> acc
      Mul(left, right) -> #(val |> int.add(left * right), should_process)
    }
  })
  |> pair.first
  |> int.to_string
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
