defmodule Directed.Vertex do
  use GenEvent
  alias Directed.Message

  defmacro __using__(options) do
    mode = Keyword.get(options, :mode) || :normal

    quote do
      @mode unquote(mode)

      def init(output_manager) do
        {:ok, %{output_manager: output_manager}}
      end

      def handle_event(:done, state) do
        Directed.Vertex.finish(__MODULE__, @mode, state)
      end

      def handle_event(record, state) do
        Directed.Vertex.process(__MODULE__, @mode, state, record)
      end
    end
  end

  def process(module, _mode, state, record) do
    record
    |> module.process
    |> Message.emit(state.output_manager)

    {:ok, state}
  end

  def finish(module, _mode, state) do
    Message.emit(:done, state.output_manager)
    {:ok, state}
  end
end
