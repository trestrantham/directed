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
end
