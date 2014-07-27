defmodule Directed.Vertex do
  use GenEvent

  defmacro __using__(_options) do
    quote do
      alias Directed.Message

      def init(output_manager) do
        {:ok, output_manager}
      end

      def handle_event(:done, output_manager) do
        Message.emit(:done, output_manager)

        {:ok, output_manager}
      end

      def handle_event(message, output_manager) do
        message |> process |> Message.emit(output_manager)

        {:ok, output_manager}
      end
    end
  end
end
