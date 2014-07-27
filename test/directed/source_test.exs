defmodule Directed.SourceTest do
  use ExUnit.Case

  defmodule TestSource do
    use Directed.Source

    def run do
      for x <- 1..3, do: x
    end
  end

  defmodule EmitSource do
    use Directed.Source, emit: :explicit

    def run(manager) do
      for x <- 10..1 do
        Message.emit(x, manager)
      end
    end
  end

  defmodule TestHandler do
    use GenEvent

    def handle_event(event, parent) do
      send parent, event
      {:ok, parent}
    end
  end

  test "#run sends :done to output_manager when processing is complete" do
    {:ok, input_manager} = GenEvent.start_link
    {:ok, output_manager} = GenEvent.start_link

    GenEvent.add_handler(input_manager, TestSource, output_manager, link: true)
    GenEvent.add_handler(output_manager, TestHandler, self, link: true)

    GenEvent.sync_notify(input_manager, :start)

    :timer.sleep 100

    assert_received :done
  end

  test "#run sends output to output manager" do
    {:ok, input_manager} = GenEvent.start_link
    {:ok, output_manager} = GenEvent.start_link

    GenEvent.add_handler(input_manager, TestSource, output_manager, link: true)
    GenEvent.add_handler(output_manager, TestHandler, self, link: true)

    GenEvent.sync_notify(input_manager, :start)

    :timer.sleep 100

    assert_received 1
    assert_received 2
    assert_received 3

    GenEvent.stop(input_manager)
    GenEvent.stop(output_manager)
  end

  test "#run can emit messages manually" do
    {:ok, input_manager} = GenEvent.start_link
    {:ok, output_manager} = GenEvent.start_link

    GenEvent.add_handler(input_manager, EmitSource, output_manager, link: true)
    GenEvent.add_handler(output_manager, TestHandler, self, link: true)

    GenEvent.sync_notify(input_manager, :start)

    :timer.sleep 100

    for x <- 10..1 do
      assert_received x
    end

    GenEvent.stop(input_manager)
    GenEvent.stop(output_manager)
  end
end
