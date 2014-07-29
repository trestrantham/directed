defmodule Directed.SinkTest do
  use ExUnit.Case

  defmodule TestSink do
    use Directed.Sink

    def process(params, record) do
      File.write! params.file, to_string(record), [:append]
    end
  end

  defmodule AggregateSink do
    use Directed.Sink, mode: :aggregate

    def process(_params, record, records) do
      [record |> to_string |> String.upcase | records]
    end

    def finish(params, records) do
      File.write! params.file, records |> Enum.reverse |> Enum.join, [:append]
    end
  end

  def randstring(size) do
    chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    Enum.reduce 0..size, "", fn(_, acc) -> acc <> String.at(chars, :random.uniform(String.length(chars)) - 1) end
  end

  setup do
    file = "/tmp/#{randstring(25)}.tmp"
    File.touch file

    on_exit fn ->
      File.rm file
    end

    {:ok, file: file}
  end

  test "#process is called for each input record", %{file: file} do
    {:ok, input_manager} = GenEvent.start_link
    GenEvent.add_handler(input_manager, TestSink, %{file: file})

    for x <- ["foo", "bar", "baz"] do
      GenEvent.sync_notify(input_manager, x)
    end
    GenEvent.sync_notify(input_manager, :done)

    assert File.read!(file) == "foobarbaz"
  end

  test "#finish is called after all records have been received when set to aggregate", %{file: file} do
    {:ok, input_manager} = GenEvent.start_link
    GenEvent.add_handler(input_manager, AggregateSink, %{file: file})

    for x <- ["foo", "bar", "baz"] do
      GenEvent.sync_notify(input_manager, x)
    end
    GenEvent.sync_notify(input_manager, :done)

    assert File.read!(file) == "FOOBARBAZ"
  end
end
