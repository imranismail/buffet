defmodule Buffet do
  defmacro defproto(protobuf) do
    with {:ok, parse_tree, _context, _, _, _} <- Buffet.Parser.parse(protobuf) do
      Buffet.Compiler.compile(parse_tree)
    else
      {:error, reason, _context, _, _, _} ->
        raise RuntimeError, message: reason
    end
  end
end
