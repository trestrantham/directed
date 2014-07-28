defmodule Directed.Message do
  def emit([message | tail], event_manager) do
    emit(message, event_manager)
    emit(tail, event_manager)
  end

  def emit([], _event_manager), do: nil
  
  def emit(message, event_manager) do
    GenEvent.notify(event_manager, message)
  end
end
