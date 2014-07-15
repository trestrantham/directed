defmodule Directed.Group.Supervisor do
  use Supervisor

  def start_link do
    :supervisor.start_link({:local, __MODULE__}, __MODULE__, [])
  end

  def init(_) do
    tree = [worker(Directed.Group.Server, [])]
    supervise tree, strategy: :one_for_one
  end
end
