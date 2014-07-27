defmodule Directed.VertexTest do
  use ExUnit.Case

  defmodule TestVertex do
    use Directed.Vertex

    def process(message) do
      message |> to_string |> String.upcase
    end
  end

  defmodule TestHandler do
    use GenEvent

    def handle_event(event, parent) do
      send parent, event
      {:ok, parent}
    end
  end

  test "#process runs the defined transform on each incoming message" do
    {:ok, input_manager} = GenEvent.start_link
    {:ok, output_manager} = GenEvent.start_link

    GenEvent.add_handler(input_manager, TestVertex, output_manager, link: true)
    GenEvent.add_handler(output_manager, TestHandler, self, link: true)

    for x <- ["foo", "bar", "baz"] do
      GenEvent.sync_notify(input_manager, x)
    end

    :timer.sleep 100

    assert_received "FOO"
    assert_received "BAR"
    assert_received "BAZ"
  end
end
