defmodule Buffet.Decoder do
  import NimbleParsec, only: [defparsec: 2]
  import Buffet.Statement, only: [proto_def: 0]

  def decode!(protobuf) do
    {:ok, parsed, _, _, _, _} = parse(protobuf)
    parsed
  end

  def decode(protobuf) do
    case parse(protobuf) do
      {:ok, parsed, _context, _, _, _} ->
        {:ok, parsed}

      {:error, reason, _context, _, _, _} ->
        {:error, reason}
    end
  end

  defparsec :parse, proto_def()
end
