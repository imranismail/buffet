defmodule BuffetTest do
  use ExUnit.Case
  require Buffet

  doctest Buffet

  Buffet.define """
    syntax = "proto3";

    message Foo {
      int32 bar = 1;
    }

    message Bar {
      int32 baz = 1;
    }
  """

  test "define/1" do
    foo = %Foo{}
    bar = %Bar{}

    assert foo.bar == nil
    assert bar.baz == nil
  end

  test "encode/1" do
    foo = %Foo{}
    assert {:ok, _binary} = Buffet.encode(foo)
  end
end
