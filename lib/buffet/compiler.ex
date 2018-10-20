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
end
