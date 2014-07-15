defmodule Directed.Message do
  alias Directed.Group

  def emit(:start, group),  do: Group.broadcast(group, :start)
  def emit(:done, group),   do: Group.broadcast(group, :done)
  def emit(message, group)  when is_list(message) == false, do: Group.broadcast(group, message)
  def emit([message|tail], group) do
    emit(message, group)
    emit(tail, group)
  end
  def emit([], group), do: nil
end
