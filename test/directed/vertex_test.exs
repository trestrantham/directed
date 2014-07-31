defmodule Directed.VertexTest do
  use ExUnit.Case

  test "#process runs the defined transform on each incoming message" do
    {:ok, input_manager} = GenEvent.start_link
    {:ok, output_manager} = GenEvent.start_link

    GenEvent.add_handler(input_manager, Test.Vertex, output_manager, link: true)
    GenEvent.add_handler(output_manager, Test.Handler, self, link: true)

    for x <- ["foo", "bar", "baz"] do
      GenEvent.sync_notify(input_manager, x)
    end

    :timer.sleep 100

    assert_received "FOO"
    assert_received "BAR"
    assert_received "BAZ"
  end
end
