defmodule ChatDeGrupoServer do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: ChatDeGrupoServer)
  end

  def init(init_arg) do
    {:ok, init_arg}
  end

  def get_grupo(nombre_grupo) do
    GenServer.call(ChatDeGrupoServer, {:get_grupo, nombre_grupo})
  end

  def crear_grupo(nombre_grupo, usuario_admin) do
    IO.puts("CREANDO UN GRUPO")
    GenServer.call(ChatDeGrupoServer, {:crear_grupo, nombre_grupo, usuario_admin})
  end

  def handle_call({:get_grupo, nombre_grupo}, _from, state) do
    case ChatDeGrupoRegistry.lookup(nombre_grupo) do
      [{chatPid, _}] -> {:reply, chatPid, state}
      _ -> {
        case Swarm.members({:chat_grupo_agent, nombre_grupo}) do
          [] -> {:reply, :not_found, state}
          _ ->
            {_, agente} = ChatDeGrupoAgent.start_link(nil, nombre_grupo)
            Entity.copiar(agente, {:chat_grupo_agent, nombre_grupo})
            Swarm.join({:chat_grupo_agent, nombre_grupo}, agente)
            chatPid = ChatDeGrupoSupervisor.start_child(nombre_grupo)
            {:reply, chatPid, state}
        end
      }
    end
  end

  def handle_call({:crear_grupo, nombre_grupo, usuario_admin}, _from, state) do
    case ChatDeGrupoSupervisor.start_child(nombre_grupo) do
      {:ok, pidGrupo} ->
        {:ok, pidAgent} = ChatDeGrupoAgent.start_link(usuario_admin, nombre_grupo)
        ServerEntity.agregar_chat_de_grupo(nombre_grupo)
        Swarm.join({:chat_grupo_agent, nombre_grupo}, pidAgent)
        Swarm.join({:chat_grupo, nombre_grupo}, pidGrupo)
        {:reply, nombre_grupo, state}

      {:error, {:already_started, _}} ->
        {:reply, :already_exists, state}
    end
  end

end
