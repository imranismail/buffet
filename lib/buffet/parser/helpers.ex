defmodule Buffet.Parser.Helpers do
  import NimbleParsec

  def whitespace(combinator \\ empty()) do
    repeat(
      combinator,
      ignore(utf8_string([?\s, ?\r, ?\n, ?\t, ?\f, ?\v], min: 1))
    )
  end

  def to_atom(combinator \\ empty(), to_atom) do
    map(combinator, to_atom, {String, :to_atom, []})
  end

  def to_integer(combinator \\ empty(), to_integer) do
    map(combinator, to_integer, {String, :to_integer, []})
  end

  def to_module(combinator \\ empty(), to_mod) do
    to_concat =
      to_mod
      |> map({List, :wrap, []})
      |> map({Module, :concat, []})

    concat(combinator, to_concat)
  end
end
