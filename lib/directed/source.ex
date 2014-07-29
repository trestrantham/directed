defmodule Directed.Source do
  use GenEvent

  defmacro __using__(options) do
    emit = Keyword.get(options, :emit) || :implicit

    quote do
      alias Directed.Message
      @emit unquote(emit)

      def init(output_manager) do
        {:ok, output_manager}
      end

      def handle_event(:start, output_manager) do
        start_run(@emit, output_manager)
        Message.emit(:done, output_manager)
        {:ok, output_manager}
      end

      cond do
        @emit == :implicit ->
          defp start_run(:implicit, output_manager), do: run |> Message.emit(output_manager)
        @emit == :explicit ->
          defp start_run(:explicit, output_manager), do: run(output_manager)
      end
    end
  end
end
