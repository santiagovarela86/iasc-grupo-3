defmodule PigeonTest do
  use ExUnit.Case
  doctest Pigeon

  def init(init_arg) do
    {:ok, init_arg}
  end

  test "Start a Router" do

    {:ok, pid} = BuilderHelper.makeARouter()
    assert(pid, "Not initialize")
  end

  test "Start Router twice" do

    {:ok, pid1} = BuilderHelper.makeARouter()
    {:error, {:already_started, pid2}} = BuilderHelper.makeARouter()
    assert(pid1 == pid2)
  end


  test "Start a Server" do

    BuilderHelper.makeAServer()
  end

  test "Start a Client" do

    {:ok, pid} = BuilderHelper.makeAClient()
    assert(pid, "Not initialize")
  end

  test "Simple Chat" do
    GenServer.start_link(__MODULE__, PigeonTest)
    {:ok, routerPid} = BuilderHelper.makeARouter()
    {:error, {:already_started, serverPid}} = BuilderHelper.makeAServer()
    {:ok, cPid1} = BuilderHelper.makeAClient()
    {:ok, cPid2} = BuilderHelper.makeAClient()
    {:ok, clientPid1} = BuilderHelper.makeAUser("user1")
    {:ok, clientPid2} = BuilderHelper.makeAUser("user2")
    assert(clientPid1 != clientPid2)

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

  def makeAUser(named) do

    Cliente.start_link(named)
  end

end
