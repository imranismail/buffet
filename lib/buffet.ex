defmodule Buffet do
  defmacro define(protobuf) do
    with {:ok, parse_tree, _context, _, _, _} <- Buffet.Parser.parse(protobuf) do
      parse_tree
      |> IO.inspect()
      |> Buffet.Compiler.compile()
    else
      {:error, reason, _context, _, _, _} ->
        raise RuntimeError, message: reason
    end
  end
end
