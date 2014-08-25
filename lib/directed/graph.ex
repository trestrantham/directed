defmodule Directed.Graph do
  use GenServer

  defmacro source(name, options) when is_atom(name)
                                 when is_list(options) do
    quote bind_quoted: [name: name, options: options] do
      @nodes {:source, name, options}
    end
  end

  defmacro vertex(name, options) when is_atom(name)
                                 when is_list(options) do
    quote bind_quoted: [name: name, options: options] do
      @nodes {:vertex, name, options}
    end
  end

  defmacro sink(name, options) when is_atom(name)
                               when is_list(options) do
    quote bind_quoted: [name: name, options: options] do
      @nodes {:sink, name, options}
    end
  end

  defmacro __using__(_options) do
    quote do
      Module.register_attribute __MODULE__, :nodes, accumulate: true, persist: false
      @before_compile unquote(__MODULE__)
      import unquote(__MODULE__)

      @doc """
      Starts the graph
      """
      def start_link(opts \\ []) do
        GenServer.start_link(__MODULE__, :ok, opts)
      end

      @doc """
      Starts execution of the graph

      Returns `{:ok, pid}` if execution starts successfully, `:error` otherwise.
      """
      def run(graph) do
        GenServer.call(graph, :start)
      end

      def handle_call(:start, _from, state) do
        IO.puts "handle_call: state => #{inspect(state)}"
        GenEvent.sync_notify(state.graph_manager, :start)
        {:reply, :ok, state}
      end
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      def init(:ok) do
        {:ok, graph_manager} = GenEvent.start_link
        {:ok, state} = %{graph_manager: graph_manager, managers: %{}}
                       |> start_nodes(@nodes)
                       |> attach_handlers(@nodes)
        {:ok, state}
      end
    end
  end

  def start_nodes([], state), do: state
  def start_nodes([node | nodes], state) do
    {type, name, _options} = node
    {:ok, manager} = GenEvent.start_link
    managers = state.managers |> Map.put(name, manager)
    start_nodes(nodes, Map.put(state, :managers, managers))
  end
  def start_nodes(state, nodes), do: start_nodes(nodes, state)

  def attach_handlers([], state) do
    # if orphans do
      # {:error, :orphans}
    # else
      {:ok, state}
    # end
  end
  def attach_handlers([node | nodes], state) do
    {type, name, options} = node

    if type == :source do
      GenEvent.add_handler(state.graph_manager, options[:module], Map.get(state.managers, name))
    else
      [options[:input], options[:inputs]]
      |> List.flatten
      |> Enum.reject(&(&1 === nil))
      |> Enum.each(fn(input) ->
           GenEvent.add_handler(Map.get(state.managers, input), options[:module], Map.get(state.managers, name))
         end)
    end

    attach_handlers(nodes, state)
  end
  def attach_handlers(state, nodes), do: attach_handlers(nodes, state)
end
