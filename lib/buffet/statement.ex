defmodule Buffet.Statement do
  import NimbleParsec
  import Buffet.LexicalElements
  import Buffet.Helpers

  # Syntax

  def syntax_def(combinator \\ empty()) do
    combinator
    |> ignore(string("syntax"))
    |> whitespace()
    |> ignore(utf8_string([?=], 1))
    |> whitespace()
    |> quote_symbol()
    |> string("proto3")
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
    reduce(
      combinator,
      choice([
        ident(),
        utf8_string([?(], 1)
        |> full_ident()
        |> utf8_string([?)], 1)
      ])
      |> repeat(utf8_string([?.], 1) |> ident()),
      {List, :to_string, []}
    )
  end

  # Fields

  ## Normal Field

  def field_def(combinator \\ empty()) do
    combinator
    |> map(optional(string("repeated")), {Kernel, :==, ["repeated"]})
    |> whitespace()
    |> type()
    |> whitespace()
    |> field_name()
    |> whitespace()
    |> ignore(utf8_string([?=], 1))
    |> whitespace()
    |> field_number()
    |> whitespace()
    |> optional(
      utf8_string([?[], 1)
      |> whitespace()
      |> field_options()
      |> whitespace()
      |> utf8_string([?]], 1)
    )
    |> whitespace()
    |> end_of_statement()
    |> tag(:field)
  end

  def type(combinator \\ empty()) do
    choice(combinator, [
      string("double"),
      string("float"),
      string("int32"),
      string("int64"),
      string("uint32"),
      string("uint64"),
      string("sint32"),
      string("sint64"),
      string("fixed32"),
      string("fixed64"),
      string("sfixed32"),
      string("sfixed64"),
      string("bool"),
      string("string"),
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
    combinator
    |> ignore(utf8_string([?{], 1))
    |> whitespace()
    |> repeat_until(
      choice([field_def(), option_def(), one_of_def(), end_of_statement()]) |> whitespace(),
      [utf8_string([?}], 1)]
    )
    |> whitespace()
    |> ignore(utf8_string([?}], 1))
  end

  # Proto file

  def proto_def(combinator \\ empty()) do
    combinator
    |> whitespace()
    |> syntax_def()
    |> whitespace()
    |> repeat(
      choice([
        import_def(),
        package_def(),
        option_def(),
        top_level_def(),
        end_of_statement()
      ])
      |> whitespace()
    )
  end
end
