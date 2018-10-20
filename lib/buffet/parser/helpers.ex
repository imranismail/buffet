defmodule Buffet.Parser.Helpers do
  import NimbleParsec

  def whitespace(combinator \\ empty()) do
    repeat(
      combinator,
      ignore(utf8_string([?\s, ?\r, ?\n, ?\t, ?\f, ?\v], min: 1))
    )
  end

  def atom(combinator \\ empty(), content) do
    map(combinator, string(content), {String, :to_atom, []})
  end
end
