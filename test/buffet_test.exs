defmodule BuffetTest do
  use ExUnit.Case
  require Buffet

  doctest Buffet

  Buffet.define """
    syntax = "proto3";

    enum EnumAllowingAlias {
      option allow_alias = true;

      UNKNOWN = 0;

      STARTED = 1;

      RUNNING = 2 [(custom_option) = "hello world"];
    }

    message Outer {
      int64 oval = 1;

      Foo.Bar nested_message = 2;

      repeated int32 samples = 4 [packed=true];

      message Inner {
        int64 ival = 1;
      }
    }
  """

  test "define/1" do
    # assert outer = %Outer{}
  end
end
