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

  def list_to_string(combinator \\ empty(), list) do
    reduce(combinator, list, {List, :to_string, []})
  end

  def camelize(combinator \\ empty(), to_camelize) do
    map(combinator, to_camelize, {Macro, :camelize, []})
  end
end
