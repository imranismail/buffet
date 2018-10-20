defmodule Buffet.Compiler.Syntax do
  def compile(children) do
    case children do
      [:proto3] -> :ok
      [unknown] -> raise RuntimeError, message: "#{unknown} syntax set"
    end
  end
end