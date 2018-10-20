defmodule Buffet.Parser.Statement do
  import NimbleParsec
  import Buffet.Parser.LexicalElements
  import Buffet.Parser.Helpers

  # Syntax

  def syntax_def(combinator \\ empty()) do
    combinator
    |> ignore(string("syntax"))
    |> whitespace()
    |> ignore(utf8_string([?=], 1))
    |> whitespace()
    |> quote_symbol()
    |> atom("proto3")
    |> quote_symbol()
    |> whitespace()
    |> end_of_statement()
    |> tag(:syntax)
  end

  # Import

  def import_def(combinator \\ empty()) do
    combinator
    |> ignore(string("import"))
    |> whitespace()
    |> optional(
      choice([
        string("weak"),
        string("public")
      ])
    )
    |> whitespace()
    |> str_lit()
    |> whitespace()
    |> end_of_statement()
    |> tag(:import)
  end

  # Package

  def package_def(combinator \\ empty()) do
    combinator
    |> string("package")
    |> whitespace()
    |> full_ident()
    |> whitespace()
    |> end_of_statement()
    |> tag(:package)
  end

  # Option

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
      |> reduce({List, :to_string, []})

    concat(combinator, to_concat)
  end

  # Fields

  ## Normal Field

  def field_def(combinator \\ empty()) do
    options =
      utf8_string([?[], 1)
      |> whitespace()
      |> field_options()
      |> whitespace()
      |> utf8_string([?]], 1)

    combinator
    |> map(optional(string("repeated")), {Kernel, :==, ["repeated"]})
    |> whitespace()
    |> type()
    |> whitespace()
    |> field_name()
    |> whitespace()
    |> ignore(utf8_string([?=], 1))
    |> whitespace()
    |> map(field_number(), {String, :to_integer, []})
    |> whitespace()
    |> optional(options)
    |> whitespace()
    |> end_of_statement()
    |> tag(:field)
  end

  def type(combinator \\ empty()) do
    choice(combinator, [
      atom("double"),
      atom("float"),
      atom("int32"),
      atom("int64"),
      atom("uint32"),
      atom("uint64"),
      atom("sint32"),
      atom("sint64"),
      atom("fixed32"),
      atom("fixed64"),
      atom("sfixed32"),
      atom("sfixed64"),
      atom("bool"),
      atom("string"),
      message_type(),
      enum_type()
    ])
  end

  def field_number(combinator \\ empty()) do
    int_lit(combinator)
  end

  def field_option(combinator \\ empty()) do
    combinator
    |> option_name()
    |> whitespace()
    |> utf8_string([?=], 1)
    |> whitespace()
    |> constant()
  end

  def field_options(combinator \\ empty()) do
    combinator
    |> field_option()
    |> whitespace()
    |> repeat_until(
      utf8_string([?,], 1)
      |> whitespace()
      |> field_option(),
      [utf8_string([?]], 1)]
    )
  end

  ## Oneof and Oneof field

  def one_of_def(combinator \\ empty()) do
    combinator
    |> string("oneof")
    |> whitespace()
    |> one_of_name()
    |> whitespace()
    |> utf8_string([?{], 1)
    |> whitespace()
    |> repeat_until(
      one_of_field() |> whitespace(),
      [utf8_string([?}], 1)]
    )
    |> whitespace()
    |> utf8_string([?}], 1)
  end

  def one_of_field(combinator \\ empty()) do
    combinator
    |> type()
    |> whitespace()
    |> field_name()
    |> whitespace()
    |> utf8_string([?=], 1)
    |> whitespace()
    |> field_number()
    |> whitespace()
    |> optional(
      utf8_string([?[], 1)
      |> field_options()
      |> utf8_string([?]], 1)
    )
    |> whitespace()
    |> end_of_statement()
  end

  ## Map field

  # Reserved

  # Top level definitions
  def top_level_def(combinator \\ empty()) do
    message_def(combinator)
    # choice(combinator, [
    #   message_def(),
    # ])
  end

  ## Message

  def message_def(combinator \\ empty()) do
    combinator
    |> ignore(string("message"))
    |> whitespace()
    |> unwrap_and_tag(message_name(), :name)
    |> whitespace()
    |> tag(message_body(), :body)
    |> tag(:message)
  end

  def message_body(combinator \\ empty()) do
    body_def_choice =
      [field_def(), option_def(), one_of_def(), empty_statement()]
      |> choice()
      |> whitespace()

    combinator
    |> ignore(utf8_string([?{], 1))
    |> whitespace()
    |> repeat_until(body_def_choice, [utf8_string([?}], 1)])
    |> whitespace()
    |> ignore(utf8_string([?}], 1))
  end

  # Proto file

  def proto_def(combinator \\ empty()) do
    proto_def_choice =
      [import_def(), package_def(), option_def(), top_level_def(), empty_statement()]
      |> choice()
      |> whitespace()

    combinator
    |> whitespace()
    |> syntax_def()
    |> whitespace()
    |> repeat(proto_def_choice)
  end
end
