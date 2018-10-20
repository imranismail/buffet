defmodule Buffet.Parser do
  import NimbleParsec
  import Buffet.Parser.Helpers
  import Buffet.Parser.LexicalElements

  # Proto

  defparsec :parse,
    whitespace()
    |> parsec(:syntax)
    |> whitespace()
    |> repeat(
      [parsec(:import), parsec(:package), parsec(:option), parsec(:top_level_def), empty_statement()]
      |> choice()
      |> whitespace()
    )

  # Syntax

  defcombinatorp :syntax,
    ignore(string("syntax"))
    |> whitespace()
    |> ignore(utf8_string([?=], 1))
    |> whitespace()
    |> quote_symbol()
    |> to_atom(string("proto3"))
    |> quote_symbol()
    |> whitespace()
    |> end_of_statement()
    |> tag(:syntax)

  # Import

  defcombinatorp :import,
    ignore(string("import"))
    |> whitespace()
    |> optional(
      choice([
        to_atom(string("weak")),
        to_atom(string("public"))
      ])
    )
    |> whitespace()
    |> str_lit()
    |> whitespace()
    |> end_of_statement()
    |> tag(:import)

  # Package

  defcombinatorp :package,
    string("package")
    |> whitespace()
    |> full_ident()
    |> whitespace()
    |> end_of_statement()
    |> tag(:package)

  # Option

  defcombinatorp :option,
    ignore(string("option"))
    |> whitespace()
    |> option_name()
    |> whitespace()
    |> to_atom(utf8_string([?=], 1))
    |> whitespace()
    |> constant()
    |> whitespace()
    |> end_of_statement()
    |> tag(:option)

  # Field

  defcombinatorp :field,
    optional(to_atom(string("repeated")))
    |> whitespace()
    |> type()
    |> whitespace()
    |> field_name()
    |> whitespace()
    |> to_atom(utf8_string([?=], 1))
    |> whitespace()
    |> field_number()
    |> whitespace()
    |> optional(field_options())
    |> whitespace()
    |> end_of_statement()
    |> tag(:field)

  defcombinatorp :oneof,
    ignore(string("oneof"))
    |> whitespace()
    |> oneof_name()
    |> whitespace()
    |> utf8_string([?{], 1)
    |> whitespace()
    |> repeat_until(
      oneof_field() |> whitespace(),
      [utf8_string([?}], 1)]
    )
    |> whitespace()
    |> utf8_string([?}], 1)
    |> tag(:oneof)

  defcombinatorp :map,
    ignore(string("map"))
    |> whitespace()
    |> utf8_string([?<], 1)
    |> whitespace()
    |> map_key_type()
    |> whitespace()
    |> utf8_string([?>], 1)
    |> whitespace()
    |> map_name()
    |> whitespace()
    |> to_atom(utf8_string([?=], 1))
    |> whitespace()
    |> field_number()
    |> whitespace()
    |> optional(field_options())
    |> whitespace()
    |> end_of_statement()
    |> tag(:map)

  defcombinatorp :reserved,
    ignore(string("reserved"))
    |> whitespace()
    |> choice([
      ranges(),
      field_names()
    ])
    |> whitespace()
    |> end_of_statement()
    |> tag(:reserved)

  defcombinatorp :enum,
    ignore(string("enum"))
    |> whitespace()
    |> unwrap_and_tag(to_module(enum_name()), :name)
    |> whitespace()
    |> enum_body()
    |> tag(:enum)

  defcombinatorp :message,
    ignore(string("message"))
    |> whitespace()
    |> unwrap_and_tag(to_module(message_name()), :name)
    |> whitespace()
    |> parsec(:message_body)
    |> tag(:message)

  defcombinatorp :message_body,
    ignore(utf8_string([?{], 1))
    |> whitespace()
    |> repeat_until(whitespace(choice([parsec(:field), parsec(:enum), parsec(:message), parsec(:option), parsec(:oneof), parsec(:map), parsec(:reserved), empty_statement()])), [utf8_string([?}], 1)])
    |> whitespace()
    |> ignore(utf8_string([?}], 1))
    |> tag(:body)

  defcombinatorp :service,
    ignore(string("service"))
    |> whitespace()
    |> unwrap_and_tag(service_name(), :name)
    |> whitespace()
    |> tag(
      ignore(utf8_string([?{], 1))
      |> whitespace()
      |> repeat_until(
        [parsec(:option), parsec(:rpc), empty_statement()]
        |> choice()
        |> whitespace(),
        [utf8_string([?}], 1)]
      )
      |> whitespace()
      |> ignore(utf8_string([?}], 1)),
      :body
    )
    |> tag(:service)

  defcombinatorp :rpc,
    ignore(string("rpc"))
    |> whitespace()
    |> rpc_name()
    |> whitespace()
    |> utf8_string([?(], 1)
    |> whitespace()
    |> optional(string("stream"))
    |> whitespace()
    |> message_type()
    |> whitespace()
    |> utf8_string([?)], 1)
    |> whitespace()
    |> string("returns")
    |> whitespace()
    |> utf8_string([?(], 1)
    |> whitespace()
    |> optional(string("stream"))
    |> whitespace()
    |> message_type()
    |> whitespace()
    |> utf8_string([?)], 1)
    |> whitespace()
    |> concat(choice([
      utf8_string([?{], 1)
      |> whitespace()
      |> repeat_until(
        [parsec(:option), empty_statement()]
        |> choice()
        |> whitespace(),
        [utf8_string([?}], 1)]
      )
      |> whitespace()
      |> utf8_string([?}], 1),
      end_of_statement()
    ]))
    |> tag(:rpc)

  defcombinatorp :top_level_def,
    choice([
      parsec(:message),
      parsec(:enum),
      parsec(:service)
    ])
end
