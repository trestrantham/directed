defmodule Directed.GraphTest do
  use ExUnit.Case

  test "initializes the graph" do
    {:ok, graph} = Test.Graph.start_link
    Test.Graph.run(graph)
  end
end
