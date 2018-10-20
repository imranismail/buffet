defmodule Buffet.Compiler.Message do
  alias Buffet.Compiler.MessageBody

  def compile(children) do
    message_name = Keyword.fetch!(children, :name)
    message_body = Keyword.fetch!(children, :body)

    quote do
      defmodule Module.concat(__MODULE__, unquote message_name) do
        unquote MessageBody.compile(message_body)
      end
    end
  end
end