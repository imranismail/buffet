defmodule Buffet.Parser do
  import NimbleParsec, only: [defparsec: 2]
  import Buffet.Statement, only: [proto_def: 0]

  def parse!(proto) do
    {:ok, parsed, _, _, _, _} = parse_proto(proto)
    parsed
  end

  def parse(proto) do
    case parse_proto(proto) do
      {:ok, parsed, _context, _, _, _} ->
        {:ok, parsed}
      {:error, reason, _context, _, _, _} ->
        {:error, reason}
    end
  end

  defparsec :parse_proto, proto_def()
end
