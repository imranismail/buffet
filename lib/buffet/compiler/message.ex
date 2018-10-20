defmodule Buffet.Compiler.Message do
  alias Buffet.Compiler.MessageBody

  def compile(children) do
    message_name = Keyword.fetch!(children, :name)

    message_body =
      children
      |> Keyword.fetch!(:body)
      |> MessageBody.compile()

    Module.create(message_name, message_body, Macro.Env.location(__ENV__))
  end
end