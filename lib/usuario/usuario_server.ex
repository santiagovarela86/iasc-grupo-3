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
    lookup = UsuarioRegistry.lookup_user(username)
    result = case lookup do
      [{userPid, _}] -> {:reply, userPid, state}
      _ -> {:reply, :not_found, state}
    end
    result
  end

  def handle_call({:register_user, username}, _from, state) do
    {:ok, agent} = UsuarioAgent.start_link(username)
    Swarm.join(username, agent)
    #tendria que usar un supervisor para crear al agent
    #tendria que usar un case, o el case ya hecho para cuando ya existe, o cuando no existe el grupo, etc?
    case UsuarioSupervisor.start_child(username) do
      {:ok, pid} -> {:reply, pid, state}
      {:error, {:already_started, pid}} -> {:reply, pid, state}
    end
  end
end
