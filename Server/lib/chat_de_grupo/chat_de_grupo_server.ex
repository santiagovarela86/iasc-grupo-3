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
    {:reply, get_private(nombre_grupo), state}

  end

  def handle_call({:crear, nombre_grupo, usuario_admin}, _from, state) do
   case get_private(nombre_grupo) do
    {:ok, pid} -> {:reply, {:already_exists, pid}, state}
    {:not_found, nil} ->
      {:ok, chatPid} = ChatDeGrupoSupervisor.start_child(nombre_grupo, usuario_admin)
      Task.start(fn () -> GenServer.multi_call(Router.servers(Node.self), ChatDeGrupoServer, {:crear, nombre_grupo, usuario_admin}) end)
      {:reply, {:ok, chatPid}, state}
   end
  end


  defp get_private(nombre_grupo) do
    case Swarm.whereis_name({:chat_de_grupo, Node.self(), nombre_grupo}) do
      :undefined ->
        case Swarm.members({:chat_de_grupo_agent, nombre_grupo}) do
          [] -> {:not_found, nil}
          _ ->
            {:ok, chatPid} = ChatDeGrupoSupervisor.start_child(nombre_grupo, nil)
            {:ok, chatPid}
        end
      pid -> {:ok, pid}
    end
  end

end
