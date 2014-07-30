defmodule Directed.Source do
  use GenEvent
  alias Directed.Message

  defmacro __using__(options) do
    emit = Keyword.get(options, :emit) || :implicit

    quote do
      alias Directed.Message
      @emit unquote(emit)

      def init(output_manager) do
        {:ok, output_manager}
      end

      def handle_event(:start, output_manager) do
        Directed.Source.start(__MODULE__, @emit, output_manager)
      end
    end
  end

  def start(module, emit, output_manager) do
    start_run(module, emit, output_manager)
    Message.emit(:done, output_manager)
    {:ok, output_manager}
  end

  def start_run(module, :implicit, output_manager) do
    module.run |> Message.emit(output_manager)
  end
  def start_run(module, :explicit, output_manager) do
    module.run(output_manager)
  end
end
