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

  test "#broadcast publishes message to each subscriber" do
    assert Group.create("group9") == :ok
    Group.subscribe(self, "group9")
    Group.broadcast "group9", :ping
    assert_received :ping
  end

  test "#broadcast does not publish message to other group subscribers" do
    pids = Enum.map 0..10, fn _ -> spawn_pid end
    assert Group.create("group10") == :ok
    pids |> Enum.each(&Group.subscribe(&1, "group10"))
    Group.broadcast "group10", :ping
    refute_received :ping
    pids |> Enum.each(&Process.exit &1, :kill)
  end

  test "#broadcast_from does not publish to publisher pid when provided" do
    assert Group.create("group11") == :ok
    Group.subscribe(self, "group11")
    Group.broadcast_from self, "group11", :ping
    refute_received :ping
  end
end
