defmodule Directed.Sink do
  use GenEvent

  defmacro __using__(options) do
    mode = Keyword.get(options, :mode) || :normal

    quote do
      @mode unquote(mode)

      def init(params) do
        {:ok, %{params: params, records: []}}
      end

      def handle_event(:done, state) do
        Directed.Sink.finish(__MODULE__, @mode, state)
      end

      def handle_event(record, state) do
        Directed.Sink.process(__MODULE__, @mode, state, record)
      end
    end
  end

  def process(module, :normal, state, record) do
    module.process(state.params, record)
    {:ok, state}
  end
  def process(module, :aggregate, state, record) do
    records = module.process(state.params, record, state.records)
    {:ok, %{state | records: records}}
  end

  def finish(module, :aggregate, state) do
    module.finish(state.params, state.records)
    {:ok, state}
  end
  def finish(_module, _mode, state), do: {:ok, state}
end
