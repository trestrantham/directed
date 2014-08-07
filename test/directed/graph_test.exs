defmodule Directed.GraphTest do
  use ExUnit.Case

  test "initializes the graph" do
    {:ok, _graph} = Test.Graph.start_link
  end
end
