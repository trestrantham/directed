defmodule Directed.Group do
  use GenServer
  alias Directed.Group.Server

  @doc """
  Creates a Group for pubsub broadcast to subscribers

  name - The String name of the group

  Examples

  iex> Group.create("mygroup")
  :ok
  """
  def create(name) do
    :ok = call {:create, group(name)}
  end

  @doc """
  Checks if a given group is registered
  """
  def exists?(name) do
    call {:exists?, group(name)}
  end

  @doc """
  Removes a group
  """
  def delete(name) do
    call {:delete, group(name)}
  end

  @doc """
  Adds subscriber pid to given group

  Examples

  iex> Group.subscribe(self, "mygroup")
  """
  def subscribe(pid, name) do
    :ok = create(group(name))
    call {:subscribe, pid, group(name)}
  end

  @doc """
  Removes the given subscriber from the group

  Examples

  iex> Group.unsubscribe(self, "mygroup")
  """
  def unsubscribe(pid, name) do
    call {:unsubscribe, pid, group(name)}
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
  def subscribers(name) do
    case :pg2.get_members(group(name)) do
      {:error, {:no_such_group, _}} -> []
      members -> members
    end
  end

  defp call(message), do: :gen_server.call(Server.leader_pid, message)
  defp group(name), do: name |> to_string
end
