defmodule Buffet do
  def define(protobuf) do
    with {:ok, definitions} <- Buffet.Parser.parse(protobuf) do
      for {def, options} <- definitions, def == :message do
        message_name = Keyword.fetch!(options, :name)

        message_body = Keyword.fetch!(options, :body)

        module_name = Module.concat([message_name])

        fields =
          for {def, [type, name, _number]} <- message_body, def == :field do
            {String.to_atom(name), type}
          end

        contents = quote bind_quoted: [fields: fields] do
          defstruct Keyword.keys(fields)
        end

        Module.create(module_name, contents, Macro.Env.location(__ENV__))
      end
    end
  end
end
