defmodule BuffetTest do
  use ExUnit.Case
  import Buffet

  doctest Buffet

  defproto """
    syntax = "proto3";

    message Outer {
      int64 oval = 1;

      message Inner {
        int64 ival = 1;
      }
    }
  """

  test "define/1" do
    assert outer = %BuffetTest.Outer{oval: 1}
    assert inner = %BuffetTest.Outer.Inner{ival: 2}
    assert outer.oval == 1
    assert inner.ival == 2
  end
end
