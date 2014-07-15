defmodule Directed.SourceTest do
  use ExUnit.Case
  alias Directed.Group
  alias Directed.Message

  defmodule TestSource do
    use Directed.Source

    def process do
      for x <- 1..3, do: x
    end
  end

  test "#init creates a group with the given group name" do
    assert Group.exists?("test_group") == false
    assert {:ok, pid} = TestSource.init("test_group", "input_group")
    assert Group.exists?("test_group") == true

    Process.exit pid, :kill
  end

  test "#init subscribes the given input group" do
    assert Enum.empty?(Group.subscribers("input_group"))
    assert {:ok, pid} = TestSource.init("test_group", "input_group")
    assert Group.subscribers("input_group") == [pid]

    Process.exit pid, :kill
  end

  test "#process sends :done when processing is complete" do
    assert {:ok, pid} = TestSource.init("test_group", "input_group")
    Group.subscribe(self, "test_group")
    Message.emit(:start, "input_group")
    :timer.sleep 10 # let it process

    assert_received :done
  end

  test "#process sends output to output group when processing is complete" do
    assert {:ok, pid} = TestSource.init("test_group", "input_group")
    Group.subscribe(self, "test_group")
    Message.emit(:start, "input_group")
    :timer.sleep 10 # let it process

    assert_received 1
    assert_received 2
    assert_received 3
  end
end
