defmodule Buffet.Helpers do
  import NimbleParsec

  def whitespace(combinator \\ empty()) do
    repeat(
      combinator,
      ignore(utf8_string([?\s, ?\r, ?\n, ?\t, ?\f, ?\v], min: 1))
    )
  end
end
