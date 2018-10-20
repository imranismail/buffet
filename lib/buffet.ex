defmodule Buffet do
  def define(protobuf) do
    with {:ok, parse_tree, _context, _, _, _} <- Buffet.Parser.parse(protobuf) do
      Buffet.Compiler.compile(parse_tree)
    else
      {:error, reason, _context, _, _, _} ->
        {:error, reason}
    end
  end
end
