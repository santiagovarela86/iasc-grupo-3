defmodule UsuarioServer do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: UsuarioServer)
  end

  def init(init_arg) do
    {:ok, init_arg}
  end

  def get(nombre) do
    GenServer.call(UsuarioServer, {:get, nombre})
  end

  def crear(nombre) do
    IO.puts("CREANDO UN USUARIO")
    GenServer.multi_call(Router.servers(), UsuarioServer, {:crear, nombre})
  end

  def handle_call({:get, nombre}, _from, state) do
    {:reply, get_private(nombre), state}
  end

  def handle_call({:crear, nombre}, _from, state) do
   case get_private(nombre) do
    {:ok, pid} -> {:reply, {:already_exists, pid}, state}
    {:not_found, nil} ->
      {:ok, pid} = UsuarioSupervisor.start_child(nombre)
      {:reply, {:ok, pid}, state}
   end
  end

  def get_private(nombre) do
    case Swarm.whereis_name({:usuario, Node.self(), nombre}) do
      :undefined->
        case Swarm.members({:usuario_agent, nombre}) do
          [] ->
            {:not_found, nil}
          _ ->
            {:ok, pid} = UsuarioSupervisor.start_child(nombre)
            {:ok, pid}
        end
      pid -> {:ok, pid}
    end
  end

end
