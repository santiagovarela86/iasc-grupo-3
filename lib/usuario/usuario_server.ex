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
    GenServer.multi_call(Router.servers(), UsuarioServer, {:register_user, username})
    #GenServer.call(UsuarioServer, {:register_user, username})
  end

  # Registra usuario en este nodo, copiando el estado del resto del cluster
  def init_user(user) do
    GenServer.call(UsuarioServer, {:register_user, user})
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
    IO.puts("registrar user " <> username)
    {:ok, pidAgent} = UsuarioAgent.start_link(username)
    Entity.copiar(pidAgent, {:usuario_agent, username})
    Swarm.join({:usuario_agent, username}, pidAgent)
    ServerEntity.agregar_usuario(username)
    #tendria que usar un supervisor para crear al agent
    #tendria que usar un case, o el case ya hecho para cuando ya existe, o cuando no existe el grupo, etc?
    case UsuarioSupervisor.start_child(username) do
      {:ok, pid} ->
      Swarm.join({:usuario, username}, pid)
      {:reply, pid, state}
      {:error, {:already_started, pid}} -> {:reply, pid, state}
    end
  end
end
