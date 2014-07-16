defmodule Directed.Message do
  alias Directed.Group

  def emit(message, group) when is_list(message) == false do
    Group.broadcast(group, message)
  end

  def emit([message | tail], group) do
    emit(message, group)
    emit(tail, group)
  end

  def emit([], group), do: nil
end
