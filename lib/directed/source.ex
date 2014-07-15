defmodule Directed.Source do
  alias Directed.Group
  alias Directed.Message

  defmacro __using__(_) do
    quote do
      def init(output_group, input_group) do
        pid = spawn fn ->
          receive_loop(output_group)
        end

        Group.subscribe(pid, input_group)
        Group.create(output_group)

        {:ok, pid}
      end

      defp receive_loop(output_group) do
        receive do
          :start ->
            process |> Message.emit(output_group)

            Message.emit(:done, output_group)
        end
      end
    end
  end
end
