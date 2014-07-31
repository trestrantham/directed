defmodule Directed.SinkTest do
  use ExUnit.Case

  setup do
    file = "/tmp/#{Test.randstring(25)}.tmp"
    File.touch file

    on_exit fn ->
      File.rm file
    end

    {:ok, file: file}
  end

  test "#process is called for each input record", %{file: file} do
    {:ok, input_manager} = GenEvent.start_link
    GenEvent.add_handler(input_manager, Test.Sink, %{file: file})

    for x <- ["foo", "bar", "baz"] do
      GenEvent.sync_notify(input_manager, x)
    end
    GenEvent.sync_notify(input_manager, :done)

    assert File.read!(file) == "foobarbaz"
  end

  test "#finish is called after all records have been received when set to aggregate", %{file: file} do
    {:ok, input_manager} = GenEvent.start_link
    GenEvent.add_handler(input_manager, Test.AggregateSink, %{file: file})

    for x <- ["foo", "bar", "baz"] do
      GenEvent.sync_notify(input_manager, x)
    end
    GenEvent.sync_notify(input_manager, :done)

    assert File.read!(file) == "FOOBARBAZ"
  end
end
