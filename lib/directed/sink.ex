defmodule Directed.Sink do
  use GenEvent

  defmacro __using__(options) do
    mode = Keyword.get(options, :mode) || :normal

    quote do
      alias Directed.Message
      @mode unquote(mode)

      @doc false
      def process(_params, record) do
      end

      @doc false
      def process(_params, record, records) do
        [record | records]
      end

      @doc false
      def finish(_params, _records) do
      end

      defoverridable [process: 2, process: 3, finish: 2]

      def init(params) do
        {:ok, %{params: params, records: []}}
      end

      def handle_event(:done, state) do
        start_finish(@mode, state)
      end

      def handle_event(record, state) do
        start_process(@mode, state, record)
      end

      defp start_process(:normal, state, record) do
        process(state.params, record)
        {:ok, state}
      end
      defp start_process(:aggregate, state, record) do
        records = process(state.params, record, state.records)
        {:ok, %{state | records: records}}
      end

      defp start_finish(:aggregate, state) do
        finish(state.params, state.records)
        {:ok, state}
      end
      defp start_finish(_, state), do: {:ok, state}
    end
  end
end
