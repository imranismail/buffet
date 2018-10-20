defmodule Buffet.Compiler.MessageBody do
  def compile(children) do
    children
    |> Enum.group_by(fn {node, _children} -> node end, fn {_node, children} -> children end)
    |> Enum.map(fn {node, children} -> compile(node, children) end)
  end

  defp compile(:field, children) do
    fields =
      for [type, name, number] <- children do
        {name, [type, number]}
      end

    quote bind_quoted: [fields: fields] do
      @fields fields
      defstruct Keyword.keys(@fields)
    end
  end
end
