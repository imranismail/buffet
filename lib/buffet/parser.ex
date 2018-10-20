defmodule Buffet.Parser do
  import NimbleParsec, only: [defparsec: 2]
  import Buffet.Parser.Statement, only: [proto_def: 0]

  defparsec :parse, proto_def()
end
