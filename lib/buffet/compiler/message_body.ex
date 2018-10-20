defmodule Buffet.Compiler.MessageBody do
  alias Buffet.Compiler.Message

  def compile(children) do
    children
    |> Enum.group_by(fn {node, _children} -> node end, fn {_node, children} -> children end)
    |> Enum.map(fn {node, children} -> compile(node, children) end)
  end

  defp compile(:message, children), do: Enum.map(children, &Message.compile/1)
  defp compile(:field, children) do
    fields =
      Enum.map(children, fn
        [type, name, :=, number] ->
          {name, [type: type, number: number, options: [], repeated: false]}
        [type, name, :=, number, options] ->
          {name, [type: type, number: number, options: options, repeated: false]}
        [:repeated, type, name, :=, number] ->
          {name, [type: type, number: number, options: [], repeated: true]}
        [:repeated, type, name, :=, number, options] ->
          {name, [type: type, number: number, options: options, repeated: true]}
      end)

    quote bind_quoted: [fields: fields] do
      @fields fields
      defstruct Keyword.keys(@fields)
    end
  end
end
