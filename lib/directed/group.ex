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

  defp call(message), do: :gen_server.call(Server.leader_pid, message)
  defp group(name), do: name |> to_string
end
