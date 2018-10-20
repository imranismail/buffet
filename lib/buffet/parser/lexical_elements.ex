defmodule Buffet.Parser.LexicalElements do
  import NimbleParsec

  # Letters and Digits

  def letter(combinator \\ empty()) do
    utf8_string(
      combinator,
      [
        ?a..?z,
        ?A..?Z
      ],
      1
    )
  end

  def decimal_digit(combinator \\ empty()) do
    utf8_string(
      combinator,
      [
        ?0..?9
      ],
      1
    )
  end

  def octal_digit(combinator \\ empty()) do
    utf8_string(
      combinator,
      [
        ?0..?7
      ],
      1
    )
  end

  def hex_digit(combinator \\ empty()) do
    utf8_string(
      combinator,
      [
        ?0..?9,
        ?A..?F,
        ?a..?f
      ],
      1
    )
  end

  # Identifiers

  def ident(combinator \\ empty()) do
    choice_after_first_letter =
      choice([
        letter(),
        decimal_digit(),
        utf8_string([?_], 1)
      ])

    to_concat =
      letter()
      |> repeat(choice_after_first_letter)
      |> reduce({List, :to_string, []})

    concat(combinator, to_concat)
  end

  def full_ident(combinator \\ empty()) do
    sub_ident =
      ident()
      |> utf8_string([?.], 1)

    to_concat =
      ident()
      |> repeat(sub_ident)
      |> reduce({List, :to_string, []})

    concat(combinator, to_concat)
  end

  def message_name(combinator \\ empty()) do
    to_concat =
      ident()
      |> map({List, :wrap, []})
      |> map({Module, :concat, []})

    concat(combinator, to_concat)
  end

  def enum_name(combinator \\ empty()) do
    ident(combinator)
  end

  def field_name(combinator \\ empty()) do
    map(combinator, ident(), {String, :to_atom, []})
  end

  def one_of_name(combinator \\ empty()) do
    ident(combinator)
  end

  def map_name(combinator \\ empty()) do
    ident(combinator)
  end

  def service_name(combinator \\ empty()) do
    ident(combinator)
  end

  def rpc_name(combinator \\ empty()) do
    ident(combinator)
  end

  def message_type(combinator \\ empty()) do
    to_concat =
      optional(utf8_string([?.], 1))
      |> repeat(utf8_string(ident(), [?.], 1))
      |> message_name()
      |> reduce({List, :to_string, []})

    concat(combinator, to_concat)
  end

  def enum_type(combinator \\ empty()) do
    to_concat =
      optional(utf8_string([?.], 1))
      |> repeat(utf8_string(ident(), [?.], 1))
      |> enum_name()
      |> reduce({List, :to_string, []})

    concat(combinator, to_concat)
  end

  # Integer Literals

  def int_lit(combinator \\ empty()) do
    choice(combinator, [decimal_lit(), octal_lit(), hex_lit()])
  end

  def decimal_lit(combinator \\ empty()) do
    combinator
    |> utf8_string([?1..?9], 1)
    |> repeat(decimal_digit())
  end

  def octal_lit(combinator \\ empty()) do
    combinator
    |> utf8_string([?0], 1)
    |> repeat(octal_digit())
  end

  def hex_lit(combinator \\ empty()) do
    combinator
    |> utf8_string([?0], 1)
    |> utf8_string([?x, ?X], 1)
    |> hex_digit()
    |> repeat(hex_digit())
  end

  # Floating-point literals

  def float_lit(combinator \\ empty()) do
    two_decimal_places_with_exponent =
      decimals()
      |> utf8_string([?.], 1)
      |> optional(decimals())
      |> optional(exponent())

    decimal_with_exponent =
      decimals()
      |> exponent()

    one_decimal_place_with_exponent =
      utf8_string([?.], 1)
      |> decimals()
      |> optional(exponent())

    choice(combinator, [
      choice([
        two_decimal_places_with_exponent,
        decimal_with_exponent,
        one_decimal_place_with_exponent
      ]),
      string("inf"),
      string("nan")
    ])
  end

  def decimals(combinator \\ empty()) do
    combinator
    |> decimal_digit()
    |> repeat(decimal_digit())
  end

  def exponent(combinator \\ empty()) do
    combinator
    |> utf8_string([?e, ?E], 1)
    |> optional(utf8_string([?+, ?-], 1))
    |> decimals()
  end

  # Boolean

  def bool_lit(combinator \\ empty()) do
    choice(combinator, [
      string("true"),
      string("false")
    ])
  end

  # String literals

  def str_lit(combinator \\ empty()) do
    single_quoted_string =
      ignore(utf8_string([?'], 1))
      |> repeat_until(char_value(), [utf8_string([?'], 1)])
      |> ignore(utf8_string([?'], 1))

    double_quoted_string =
      ignore(utf8_string([?"], 1))
      |> repeat_until(char_value(), [utf8_string([?"], 1)])
      |> ignore(utf8_string([?"], 1))

    to_concat =
      [single_quoted_string, double_quoted_string]
      |> choice()
      |> reduce({List, :to_string, []})

    concat(combinator, to_concat)
  end

  def char_value(combinator \\ empty()) do
    choice(combinator, [
      hex_escape(),
      octal_escape(),
      char_escape(),
      optional(utf8_string([{:not, ?\n}, {:not, ?\0}, {:not, ?\\}], 1))
    ])
  end

  def hex_escape(combinator \\ empty()) do
    combinator
    |> utf8_string([?\\], 1)
    |> utf8_string([?x, ?X], 1)
    |> hex_digit()
    |> hex_digit()
  end

  def octal_escape(combinator \\ empty()) do
    combinator
    |> utf8_string([?\\], 1)
    |> octal_digit()
    |> octal_digit()
    |> octal_digit()
  end

  def char_escape(combinator \\ empty()) do
    combinator
    |> utf8_string([?\\], 1)
    |> utf8_string([?a, ?b, ?f, ?n, ?r, ?t, ?v, ?\\, ?', ?"], 1)
  end

  def quote_symbol(combinator \\ empty()) do
    ignore(combinator, utf8_string([?', ?"], 1))
  end

  # Empty Statement or End of Statement

  def empty_statement(combinator \\ empty()) do
    ignore(combinator, string(";"))
  end

  def end_of_statement(combinator \\ empty()) do
    empty_statement(combinator)
  end

  # Constant

  def constant(combinator \\ empty()) do
    choice(combinator, [
      full_ident(),
      int_lit(utf8_string([?-, ?+], 1)),
      float_lit(utf8_string([?-, ?+], 1)),
      str_lit(),
      bool_lit()
    ])
  end
end
