defmodule BuffetTest do
  use ExUnit.Case
  require Buffet

  doctest Buffet

  Buffet.define """
    syntax = "proto3";

    message Outer {
      int64 oval = 1;

      foo.bar nested_message = 2;

      repeated int32 samples = 4 [packed=true];

      message Inner {
        int64 ival = 1;
      }
    }
  """

  test "define/1" do
    assert outer = %Outer{}
  end
end
