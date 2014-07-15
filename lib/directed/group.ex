defmodule Directed.Group do
  use GenServer
  alias Directed.Group.Server

  @doc """
  Creates a Group for pubsub broadcast to subscribers

  group - The String name of the group

  Examples

  iex> Group.create("mygroup")
  :ok
  """
  def create(group) do
    :ok = call {:create, to_string(group)}
  end

  @doc """
  Checks if a given group is registered
  """
  def exists?(group) do
    call {:exists?, to_string(group)}
  end

  @doc """
  Removes a group
  """
  def delete(group) do
    call {:delete, to_string(group)}
  end

  @doc """
  Adds subscriber pid to given group

  Examples

  iex> Group.subscribe(self, "mygroup")
  """
  def subscribe(pid, group) do
    :ok = create(to_string(group))
    call {:subscribe, pid, to_string(group)}
  end

  @doc """
  Removes the given subscriber from the group

  Examples

  iex> Group.unsubscribe(self, "mygroup")
  """
  def unsubscribe(pid, group) do
    call {:unsubscribe, pid, to_string(group)}
  end

  @doc """
  Returns the list of subscriber pids of the group

  iex> Group.subscribers("mygroup")
  []
  iex> Group.subscribe(self, "mygroup")
  :ok
  iex> Group.subscribers("mygroup")
  [#PID<0.41.0>]

  """
  def subscribers(group) do
    case :pg2.get_members(to_string(group)) do
      {:error, {:no_such_group, _}} -> []
      members -> members
    end
  end

  @doc """
  Broadcasts a message to the group's subscribers

  Examples

  iex> group.broadcast("mygroup", :hello)

  To exclude the publisher from receiving the message, use #broadcast_from/3
  """
  def broadcast(group, message) do
    broadcast_from(:global, to_string(group), message)
  end

  @doc """
  Broadcasts a message to the group's subscribers, excluding
  publisher from receiving the message it sent out

  Examples

  iex> Group.broadcast_from(self, "mygroup", :hello)

  """
  def broadcast_from(from_pid, group, message) do
    to_string(group)
    |> subscribers
    |> Enum.each fn
      pid when pid != from_pid -> send(pid, message)
      _pid ->
    end
  end

  defp call(message), do: :gen_server.call(Server.leader_pid, message)
end
