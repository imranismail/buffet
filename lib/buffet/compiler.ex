defmodule Buffet.Compiler do
  alias Buffet.Compiler.Message
  alias Buffet.Compiler.Syntax

  def compile(parse_tree) do
    for {node, children} <- parse_tree do
      compile(node, children)
    end
  end

  defp compile(:syntax, children), do: Syntax.compile(children)
  defp compile(:message, children), do: Message.compile(children)
  defp compile(:enum, _children), do: {:error, :not_implemented}
  defp compile(:import, _children), do: {:error, :not_implemented}
  defp compile(:package, _children), do: {:error, :not_implemented}
  defp compile(:service, _children), do: {:error, :not_implemented}
end
