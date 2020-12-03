defmodule GrupoServer do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: GrupoServer)
  end

  def init(init_arg) do
    {:ok, init_arg}
  end

  def get_grupo(nombre_grupo) do
    GenServer.call(GrupoServer, {:get_grupo, nombre_grupo})
  end

  def crear_grupo(nombre_grupo, usuario_admin) do
    IO.puts("CREANDO UN GRUPO")
    GenServer.multi_call(Router.servers(), GrupoServer, {:crear_grupo, nombre_grupo, usuario_admin})
  end

  def handle_call({:get_grupo, nombre_grupo}, _from, state) do
    case ChatUnoAUnoRegistry.lookup_chat(nombre_grupo) do
      [{chatPid, _}] -> {:reply, chatPid, state}
      _ -> {:reply, :not_found, state}
    end
  end

  def handle_call({:crear_grupo, nombre_grupo, usuario_admin}, _from, state) do
    case GrupoSupervisor.start_child(nombre_grupo) do
      {:ok, pidGrupo} ->
        {:ok, pidAgent} = ChatDeGrupoAgent.start_link(usuario_admin, nombre_grupo)
        Swarm.join({:chat_grupo_agent, nombre_grupo}, pidAgent)
        Swarm.join({:chat_grupo, nombre_grupo}, pidGrupo)
        {:reply, nombre_grupo, state}

      {:error, {:already_started, _}} ->
        {:reply, :already_exists, state}
    end
  end

end
