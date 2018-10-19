defmodule BuffetTest do
  use ExUnit.Case
  require Buffet

  doctest Buffet

  Buffet.define("""
    syntax = "proto3";

    message Foo {
      int32 foo = 1;
    }

    message Bar {
      int32 foo = 1;
    }
  """)

  test "define/1" do
    foo = %Foo{}
    bar = %Bar{}

    IO.inspect(foo)
    IO.inspect(bar)
  end
end
