defmodule Directed.Message do
  def emit(message, event_manager) when is_list(message) == false do
    GenEvent.notify(event_manager, message)
  end

  def emit([message | tail], event_manager) do
    emit(message, event_manager)
    emit(tail, event_manager)
  end

  def emit([], event_manager), do: nil
end
