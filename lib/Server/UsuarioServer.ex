defmodule UsuarioServer do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: UsuarioServer)
  end

  def init(args) do
    {:ok, args}
  end

  def get_user(username) do
    GenServer.call(UsuarioServer, {:get_user, username})
  end

  def register_user(username) do
    GenServer.call(UsuarioServer, {:register_user, username})
  end

  def handle_call({:get_user, username}, _from, state) do
    case UsuarioRegistry.lookup_user(username) do
      [{userPid, _}] -> {:reply, userPid, state}
      _ -> {:reply, :not_found, state}
    end
  end

  def handle_call({:register_user, username}, _from, state) do
    case UsuarioSupervisor.start_child(username) do
      {:ok, _} -> {:reply, username, state}
      {:error, {:already_started, _}} -> {:reply, username, state}
    end
  end
end
