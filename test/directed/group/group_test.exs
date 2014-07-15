defmodule Directed.Group.GroupTest do
  use ExUnit.Case, async: true
  alias Directed.Group
  alias Directed.Group.Server

  test "#init creates a slave when there is already a leader" do
    {:ok, %Server{role: :slave}} = Server.init([])
  end
end
