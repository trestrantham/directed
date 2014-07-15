# cf: https://github.com/phoenixframework/phoenix/blob/master/lib/phoenix/topic/server.ex
defmodule Directed.Group.Server do
  use GenServer
  alias Directed.Group
  alias Directed.Group.Server

  defstruct role: :slave

  def start_link do
    :gen_server.start_link(__MODULE__, [], [])
  end

  def leader_pid, do: :global.whereis_name(__MODULE__)

  def init(_) do
    case :global.register_name(__MODULE__, self, &:global.notify_all_name/3) do
      :no ->
        Process.link(leader_pid)
        {:ok, %Server{role: :slave}}
      :yes ->
        {:ok, %Server{role: :leader}}
    end
  end

  def handle_call({:create, group}, _from, state) do
    if exists?(group) do
      {:reply, :ok, state}
    else
      :ok = :pg2.create(group)
      {:reply, :ok, state}
    end
  end

  def handle_call({:exists?, group}, _from, state) do
    {:reply, exists?(group), state}
  end

  def handle_call({:delete, group}, _from, state) do
    {:reply, delete(group), state}
  end

  def handle_call({:subscribe, pid, group}, _from, state) do
    {:reply, :pg2.join(group, pid), state}
  end

  def handle_call({:unsubscribe, pid, group}, _from, state) do
    {:reply, :pg2.leave(group, pid), state}
  end

  defp exists?(group) do
    case :pg2.get_closest_pid(group) do
      pid when is_pid(pid)          -> true
      {:error, {:no_process, _}}    -> true
      {:error, {:no_such_group, _}} -> false
    end
  end

  defp delete(group), do: :pg2.delete(group)
end
