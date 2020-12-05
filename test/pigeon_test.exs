defmodule PigeonTest do
  use ExUnit.Case
  doctest Pigeon

  test "Start a Router" do

    {:ok, pid} = BuilderHelper.makeARouter()
    assert(pid, "Not initialize")
  end


  test "Start a Server" do

    BuilderHelper.makeAServer()
  end

  test "Start a Client" do

    {:ok, pid} = BuilderHelper.makeAClient()
    assert(pid, "Not initialize")
  end

end

defmodule BuilderHelper do

  def makeAServer() do

    Pigeon.connect_to_cluster()
    ApplicationSupervisor.start_link(keys: :unique, name: Registry.Pigeon)
  end

  def makeARouter() do

    Router.start_link([])
  end

  def makeAClient() do

    Pigeon.connect_to_cluster()
    {:ok, spawn(fn -> :ok end)}
  end

end
