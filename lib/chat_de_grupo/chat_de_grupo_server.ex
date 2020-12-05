defmodule ChatDeGrupoServer do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: ChatDeGrupoServer)
  end

  def init(init_arg) do
    {:ok, init_arg}
  end

  def get(nombre_grupo) do
    GenServer.call(ChatDeGrupoServer, {:get, nombre_grupo})
  end

  def crear(nombre_grupo, usuario_admin) do
    IO.puts("CREANDO UN GRUPO")
    GenServer.call(ChatDeGrupoServer, {:crear, nombre_grupo, usuario_admin})
  end

  def handle_call({:get, nombre_grupo}, _from, state) do
    case ChatDeGrupoRegistry.lookup(nombre_grupo) do
      [{chatPid, _}] -> {:reply, {:ok, chatPid}, state}
      []-> {
        case Swarm.members({:chat_grupo_agent, nombre_grupo}) do
          [] -> {:reply, {:not_found, nil}, state}
          _ ->
            {_, agente} = ChatDeGrupoAgent.start_link(nil, nombre_grupo)
            ServerEntity.copiar(agente, {:chat_grupo_agent, nombre_grupo})
            Swarm.join({:chat_grupo_agent, nombre_grupo}, agente)
            chatPid = ChatDeGrupoSupervisor.start_child(nombre_grupo)
            {:reply, {:ok, chatPid}, state}
        end
      }
      error -> {:reply, {:error, error}, state}
    end
  end

  def handle_call({:crear, nombre_grupo, usuario_admin}, _from, state) do
   case get(nombre_grupo) do
    {:ok, pid} -> {:reply, {:already_exists, pid}, state}
    {:not_found, nil} ->
      {_, agente} = ChatDeGrupoAgent.start_link(usuario_admin, nombre_grupo)
      Swarm.join({:chat_grupo_agent, nombre_grupo}, agente)
      ServerEntity.agregar_chat_de_grupo(nombre_grupo)
      chatPid = ChatDeGrupoSupervisor.start_child(nombre_grupo)
      {:reply, {:ok, chatPid}, state}
    error -> {:reply, {:error, error}, state}
   end
  end

end
