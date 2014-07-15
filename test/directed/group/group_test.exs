defmodule Directed.Group.GroupTest do
  use ExUnit.Case, async: true
  alias Directed.Group
  alias Directed.Group.Server

  def spawn_pid do
    spawn fn ->
      receive do
      end
    end
  end

  test "#init creates a slave when there is already a leader" do
    {:ok, %Server{role: :slave}} = Server.init([])
  end

  test "#create adds a new process group" do
    refute Group.exists?("group1")
    assert Group.create("group1") == :ok
    assert Group.exists?("group1")
  end

  test "#create with existing group returns :ok" do
    refute Group.exists?("group2")
    assert Group.create("group2") == :ok
    assert Group.create("group2") == :ok
    assert Group.exists?("group2")
  end

  test "#delete removes process group" do
    assert Group.create("group3") == :ok
    assert Group.exists?("group3")
    assert Group.delete("group3")
    refute Group.exists?("group3")
  end

  test "#subscribers, #subscribe, #unsubscribe" do
    pid = spawn_pid
    assert Group.create("group4") == :ok
    assert Enum.empty?(Group.subscribers("group4"))
    assert Group.subscribe(pid, "group4")
    assert Group.subscribers("group4") == [pid]
    assert Group.unsubscribe(pid, "group4")
    assert Enum.empty?(Group.subscribers("group4"))
    Process.exit pid, :kill
  end
end
