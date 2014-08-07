ExUnit.start

defmodule Test do
  def randstring(size) do
    chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    Enum.reduce 0..size, "", fn(_, acc) -> acc <> String.at(chars, :random.uniform(String.length(chars)) - 1) end
  end
end

defmodule Test.Handler do
  use GenEvent

  def handle_event(event, parent) do
    send parent, event
    {:ok, parent}
  end
end

defmodule Test.Graph do
  use Directed.Graph

  source :test_source,
    module: Test.Source

  sink :test_sink,
    module: Test.Sink,
    input: :test_vertex

  vertex :test_vertex,
    module: Test.Vertex,
    inputs: [:test_source, :test_source2]

  vertex :test_vertex2,
    module: Test.Vertex2,
    inputs: [:test_vertex]

  sink :test_sink2,
    module: Test.Sink2,
    input: :test_source2

  source :test_source2,
    module: Test.Source2

  def nodes do
    @nodes
  end
end

defmodule Test.Source do
  use Directed.Source

  def run do
    for x <- 1..3, do: x
  end
end

defmodule Test.Vertex do
  use Directed.Vertex

  def process(record) do
    record |> to_string |> String.upcase
  end
end

defmodule Test.Sink do
  use Directed.Sink

  def process(params, record) do
    File.write! params.file, to_string(record), [:append]
  end
end

defmodule Test.EmitSource do
  use Directed.Source, emit: :explicit

  def run(manager) do
    for x <- 10..1 do
      Message.emit(x, manager)
    end
  end
end

defmodule Test.AggregateSink do
  use Directed.Sink, mode: :aggregate

  def process(_params, record, records) do
    [record |> to_string |> String.upcase | records]
  end

  def finish(params, records) do
    File.write! params.file, records |> Enum.reverse |> Enum.join, [:append]
  end
end
