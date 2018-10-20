defmodule Buffet.Parser.LexicalElements do
  import NimbleParsec
  import Buffet.Parser.Helpers

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
      |> list_to_string()

    concat(combinator, to_concat)
  end

  def full_ident(combinator \\ empty()) do
    sub_ident =
      ident()
      |> utf8_string([?.], 1)

    to_concat =
      ident()
      |> repeat(sub_ident)
      |> list_to_string()

    concat(combinator, to_concat)
  end

  def message_name(combinator \\ empty()) do
    camelize(combinator, ident())
  end

  def enum_name(combinator \\ empty()) do
    camelize(combinator, ident())
  end

  def field_name(combinator \\ empty()) do
    to_atom(combinator, ident())
  end

  def field_names(combinator \\ empty()) do
    repeat_field_name =
      utf8_string([?,], 1)
      |> whitespace()
      |> field_name()

    combinator
    |> field_name()
    |> whitespace()
    |> repeat_until(repeat_field_name, [utf8_string([?;], 1)])
  end

  def oneof_name(combinator \\ empty()) do
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

  def option_name(combinator \\ empty()) do
    full_ident_option_name =
      utf8_string([?(], 1)
      |> full_ident()
      |> utf8_string([?)], 1)

    sub_ident_name =
      [?.]
      |> utf8_string(1)
      |> ident()

    to_concat =
      [ident(), full_ident_option_name]
      |> choice()
      |> repeat(sub_ident_name)
      |> list_to_string()

    concat(combinator, to_concat)
  end

  def message_type(combinator \\ empty()) do
    to_concat =
      optional(utf8_string([?.], 1))
      |> repeat(utf8_string(ident(), [?.], 1))
      |> message_name()
      |> list_to_string()

    concat(combinator, to_concat)
  end

  def enum_type(combinator \\ empty()) do
    to_concat =
      optional(utf8_string([?.], 1))
      |> repeat(utf8_string(ident(), [?.], 1))
      |> enum_name()
      |> list_to_string()

    concat(combinator, to_concat)
  end

  def type(combinator \\ empty()) do
    choice(combinator, [
      to_atom(string("double")),
      to_atom(string("float")),
      to_atom(string("int32")),
      to_atom(string("int64")),
      to_atom(string("uint32")),
      to_atom(string("uint64")),
      to_atom(string("sint32")),
      to_atom(string("sint64")),
      to_atom(string("fixed32")),
      to_atom(string("fixed64")),
      to_atom(string("sfixed32")),
      to_atom(string("sfixed64")),
      to_atom(string("bool")),
      to_atom(string("string")),
      message_type(),
      enum_type()
    ])
  end

  def map_key_type(combinator \\ empty()) do
    choice(combinator, [
      to_atom(string("int32")),
      to_atom(string("int64")),
      to_atom(string("uint32")),
      to_atom(string("uint64")),
      to_atom(string("sint32")),
      to_atom(string("sint64")),
      to_atom(string("fixed32")),
      to_atom(string("fixed64")),
      to_atom(string("sfixed32")),
      to_atom(string("sfixed64")),
      to_atom(string("bool")),
      to_atom(string("string")),
    ])
  end

  # Integer Literals

  def int_lit(combinator \\ empty()) do
    to_integer(combinator, choice([decimal_lit(), octal_lit(), hex_lit()]))
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
    to_atom(combinator, choice([
      string("true"),
      string("false")
    ]))
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
      |> list_to_string()

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
      bool_lit(),
      full_ident(),
      int_lit(utf8_string([?-, ?+], 1)),
      float_lit(utf8_string([?-, ?+], 1)),
      str_lit()
    ])
  end

  # Field Elements
  def field_number(combinator \\ empty()) do
    int_lit(combinator)
  end

  def field_option(combinator \\ empty()) do
    to_concat =
      to_atom(option_name())
      |> whitespace()
      |> ignore(utf8_string([?=], 1))
      |> whitespace()
      |> constant()
      |> reduce({List, :to_tuple, []})

    concat(combinator, to_concat)
  end

  def field_options(combinator \\ empty()) do
    to_concat =
      ignore(utf8_string([?[], 1))
      |> field_option()
      |> whitespace()
      |> repeat_until(
        ignore(utf8_string([?,], 1))
        |> whitespace()
        |> field_option(),
        [utf8_string([?]], 1)]
      )
      |> ignore(utf8_string([?]], 1))
      |> reduce({List, :wrap, []})

    concat(combinator, to_concat)
  end

  # Oneof Elements

  def oneof_field(combinator \\ empty()) do
    combinator
    |> type()
    |> whitespace()
    |> field_name()
    |> whitespace()
    |> utf8_string([?=], 1)
    |> whitespace()
    |> field_number()
    |> whitespace()
    |> optional(field_options())
    |> whitespace()
    |> end_of_statement()
  end

  # Misc

  def range(combinator \\ empty()) do
    combinator
    |> int_lit()
    |> optional(choice(string("to"), [int_lit(), string("max")]))
  end

  def ranges(combinator \\ empty()) do
    repeat_range =
      utf8_string([?,], 1)
      |> whitespace()
      |> range()

    combinator
    |> range()
    |> whitespace()
    |> repeat_until(repeat_range, [utf8_string([?;], 1)])
  end

  def enum_body(combinator \\ empty()) do
    to_concat =
      ignore(utf8_string([?{], 1))
      |> whitespace()
      |> repeat_until(whitespace(choice([option_def(), enum_field(), empty_statement()])), [utf8_string([?}], 1)])
      |> whitespace()
      |> ignore(utf8_string([?}], 1))
      |> tag(:body)

    concat(combinator, to_concat)
  end

  def enum_field(combinator \\ empty()) do
    repeat_enum_value_option =
      ignore(utf8_string([?,], 1))
      |> enum_value_option()
      |> whitespace()

    options =
      utf8_string([?[], 1)
      |> ignore()
      |> whitespace()
      |> enum_value_option()
      |> whitespace()
      |> repeat_until(repeat_enum_value_option, [utf8_string([?]], 1)])
      |> whitespace()
      |> ignore(utf8_string([?]], 1))
      |> reduce({List, :wrap, []})

    to_concat =
      to_atom(ident())
      |> whitespace()
      |> to_atom(utf8_string([?=], 1))
      |> whitespace()
      |> int_lit()
      |> whitespace()
      |> optional(options)
      |> whitespace()
      |> end_of_statement()
      |> tag(:field)

    concat(combinator, to_concat)
  end

  def enum_value_option(combinator \\ empty()) do
    to_concat =
      to_atom(option_name())
      |> whitespace()
      |> ignore(utf8_string([?=], 1))
      |> whitespace()
      |> constant()
      |> reduce({List, :to_tuple, []})

    concat(combinator, to_concat)
  end

  def option_def(combinator \\ empty()) do
    combinator
    |> ignore(string("option"))
    |> whitespace()
    |> option_name()
    |> whitespace()
    |> ignore(utf8_string([?=], 1))
    |> whitespace()
    |> constant()
    |> end_of_statement()
    |> tag(:option)
  end
end
