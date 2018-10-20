defmodule BuffetTest do
  use ExUnit.Case
  require Buffet

  doctest Buffet

  Buffet.define """
    syntax = "proto3";

    message Outer {
      int64 oval = 1;

      message Inner {
        int64 ival = 1;
      }
    }
  """

  test "define/1" do
    assert outer = %BuffetTest.Outer{}
    assert inner = %BuffetTest.Outer.Inner{}
  end
end
