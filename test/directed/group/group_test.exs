defmodule Directed.Group.GroupTest do
  use ExUnit.Case, async: true
  alias Directed.Group
  alias Directed.Group.Server

  test "#init creates a slave when there is already a leader" do
    {:ok, %Server{role: :slave}} = Server.init([])
  end

  test "#create adds a new process group" do
    refute Group.exists?("group1")
    assert Group.create("group1") == :ok
    assert Group.exists?("group1")
  end
end
