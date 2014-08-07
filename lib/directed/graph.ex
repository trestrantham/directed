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
  end
end
