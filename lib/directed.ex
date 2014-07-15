defmodule Directed do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(Directed.Group.Supervisor, [])
    ]

    opts = [strategy: :one_for_one, name: Directed.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
